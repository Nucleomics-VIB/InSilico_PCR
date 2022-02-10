#!/bin/bash

# script: shotgun_16S.sh
# working with version 38.87

# required:
# bioawk: https://github.com/lh3/bioawk
# bgzip: http://www.htslib.org/download/
# BBtools: https://jgi.doe.gov/data-and-tools/bbtools/

# Stephane Plaisance VIB-NC 2020-12-01 v2.0
# version 2.0; 2020-12-01
# rewritten to handle 1 file on multiple threads
#
# visit our Git: https://github.com/Nucleomics-VIB

version="2.0; 2020-12-01"

########## start user editable region ##############

# REM: the workflow can be restarted by deleting all log files after a given step

# speed-up
thr=24
mem="24g"

# extract reads corresponding to the 16S PCR

# typical V3-V4 amplicon
forwardp="GACTCCTACGGGAGGCWGCAG"
forwardl="337F"
reversep="GACTACHVGGGTATCTAATCC"
reversel="805R"

# be stringent to avoid noisy reads
cut=0.8

# quality phred scale of your data (for demo data it is 33)
qual=33

# expected amplicon size limits, set to 10 and 10000 by default
# adjust if you notice that the sequence extraction has unwanted tail(s)
readminlen=400
readmaxlen=550

# whether to include the primer matches or to clip them (t/f)
primincl="t"

# ignore junky lines
fixjunk="t"

# keep empty lines with 'N'
fake="f"

# add label for reverse alignments
addr="t"

######## end of user editable region ############

# test arguments
if [ -z "$1" ]; then
    echo -e "\nUsage: $0 <path to a local fastq.gz file>\n"
    exit 1
fi

# extract string for output names
name=$(basename ${1%.fq.gz})

##################
# prepare folders

# run logs
logs="run_logs_${name}"
mkdir -p ${logs}

tmpout="shotgun_16S_${name}_${forwardl}_${reversel}"
mkdir -p ${tmpout}

# keep track of all
runlog=${logs}/runlog.txt
exec &> >(tee -i ${runlog})

# also echo commands to log (verbose!)
# set -x

######################################################
# find forward primer using a fraction of the threads

if [[ ! -f ${logs}/done.searching.${name}_${forwardl} ]]; then
  echo "# searching for forward primer sequence: ${forwardp}"
  px=$(basename ${1%.fq.gz})
    msa.sh -Xmx${mem} \
      threads=${thr} \
      qin=${qual} \
      in=${1} \
      out=${tmpout}/forward_${px}.sam \
      literal="${forwardp}" \
      rcomp=t \
      addr=${addr} \
      cutoff=${cut} && \
  touch ${logs}/done.searching.${name}_${forwardl}
else
  echo "# forward search already done"
fi

######################################################
# find reverse primer using a fraction of the threads

if [[ ! -f ${logs}/done.searching.${name}_${reversel} ]]; then
  echo
  echo "# searching for reverse primer sequence: ${reversep}"
  px=$(basename ${1%.fq.gz})
    msa.sh -Xmx${mem} \
      threads=${thr} \
      qin=${qual} \
      in=${1} \
      out=${tmpout}/reverse_${px}.sam \
      literal="${reversep}" \
      rcomp=t \
      addr=${addr} \
      cutoff=${cut} && \
  touch ${logs}/done.searching.${name}_${reversel}
else
  echo "# reverse search already done"
fi

##########################################
# extract regions with BBMap cutprimers.sh

if [[ ! -f ${logs}/done.cutprimer.${name}_${forwardl}_${reversel} ]]; then
  echo
  echo "# extracting amplicon sequences between primer matches"
  px=$(basename ${1%.fq.gz})
  cutprimers.sh -Xmx${mem} \
    qin=${qual} \
    in=${1} \
    out=${tmpout}/${px}_16s.fq \
    sam1=${tmpout}/forward_${px}.sam \
    sam2=${tmpout}/reverse_${px}.sam \
    include=${primincl} \
    fixjunk=${fixjunk} \
    fake=${fake} && \
  touch ${logs}/done.cutprimer.${name}_${forwardl}_${reversel}
else
  echo "# extraction already done"
fi

###########################################################
# keep only reads in amplicon size range

if [[ ! -f ${logs}/done.filtering.${name}_${forwardl}_${reversel} ]]; then
  echo
  echo "# filtering results at min:${readminlen} and max:${readmaxlen} and merging to ${final}"
  # clear existing results
  final="${name}_filtered_${forwardl}_${reversel}.fq.gz"
  cat /dev/null > ${final}
  px=$(basename ${1%.fq.gz})
  cat ${tmpout}/${px}_16s.fq | \
    bioawk -c fastx -v min="${readminlen}" -v max="${readmaxlen}" \
    '{if (length($seq)>=min && length($seq)<=max)
      print "@"$name" "$comment"\n"$seq"\n+\n"$qual}' |\
    bgzip >> ${final} && \
  touch ${logs}/done.filtering.${name}_${forwardl}_${reversel}
else
  echo "# filtering already done"
fi

