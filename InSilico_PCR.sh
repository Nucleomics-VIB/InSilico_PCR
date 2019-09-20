#!/bin/bash

# script: InSilico_PCR.sh
# Stephane Plaisance VIB-NC September-18-2019 v1.0

# script: InSilico_PCR.sh
# Stephane Plaisance VIB-NC September-18-2019 v1.0
# conda with -f environment imported
# requires: bbmap, bioawk R (computing percentiles)
#
# visit our Git: https://github.com/Nucleomics-VIB

# run once
# create a conda env to install the required apps
# conda env create -f environment.yaml

# adapt next line to point to the right conda.sh init script
# see conda activate script for details
source /etc/profile.d/conda.sh
conda activate InSilico_PCR

# get mockcommunity data from the cloud
# https://github.com/LomanLab/mockcommunity
infile=${1:-"Zymo-PromethION-EVEN-BB-SN.fq.gz"}
url=${2:-"https://nanopore.s3.climb.ac.uk"}

# extract string for output names
name=$(basename ${infile%\.fq\.gz})

# speed-up
thr=80
pigt=8
mem="8g"

# extract reads corresponding to the 16S PCR
#forwardp="AGAGTTTGATCMTGGCTCAG"
#forwardl="27F"
#reversep="CGGTWACCTTGTTACGACTT"
#reversel="1492Rw"

#forwardp="GACTCCTACGGGAGGCWGCAG"
#forwardl="337F"
#reversep="GACTACHVGGGTATCTAATCC"
#reversel="805R"

forwardp="GTGYCAGCMGCCGCGGTAA"
forwardl="515FB"
reversep="CGGTWACCTTGTTACGACTT"
reversel="1492Rw"

# be stringent to avoid noisy reads
cut=0.8

# split in 500k read bins and zip
lines=2000000

# minimum expected amplicon length
# replaced by calculating the 1% percentile from the results 
# in order to exclude very short reads
# minl=1000
# exclude the 1% shortest reads, change to 0 to disable filtering
filterperc=0.01

# prepare folders

# timestamp to support re-running
ts=$(date +%s)

# Raw data
data="RawData_${name}"
mkdir -p ${data}

# run logs
logs="run_logs"
mkdir -p ${logs}

# result folders
split="split_data_${name}"
mkdir -p ${split}

tmpout="bbmap_out_${ts}"
mkdir -p ${tmpout}

#################################
# download once only

if [[ ! -f ${logs}/done.gettingdata ]]; then
  echo "# downloading ${infile} (may take some time!)"
  cd ${data}
  wget ${url}/${infile}
  cd ../
  touch ${logs}/done.gettingdata}
else
  echo "# ${infile} was already downloaded from ${url}"
fi

###########################################
# split large file into chunks for parallel

if [[ ! -f ${logs}/done.splitting ]]; then
  echo "# splitting the data in multiple smaller files and compressing (may take some time!)"
  zcat ${data}/${infile} | split -a 3 -d -l ${lines} --filter='pigz -p '${pigt}' > $FILE.fq.gz' - ${split}/${name}_ &&
    touch  ${logs}/done.splitting
else
  echo "# splitting already done"
fi

#################################
# run in BBMap msa.sh in parallel
#################################

#####################
# find forward primer

if [[ ! -f ${logs}/done.${name}_${forwardl}.${ts} ]]; then
  echo "# searching for forward primer sequence: ${forwardp} in all files"
  find ${split} -type f -name "${name}_???.fq.gz" -printf '%P\n' |\
    sort -n |\
    parallel -j ${thr} msa.sh -Xmx${mem} qin=33 in=${split}/{} out=${tmpout}/forward_{}.sam literal="${forwardp}" rcomp=t cutoff=${cut} && \
    touch ${logs}/done.${name}_${forwardl}.${ts}
else
  echo "# forward search already done"
fi

#####################
# find reverse primer

if [[ ! -f ${logs}/done.${name}_${reversel}.${ts} ]]; then
  echo "# searching for reverse primer sequence: ${reversep} in all files"
  find ${split} -type f -name "${name}_???.fq.gz" -printf '%P\n' |\
    sort -n |\
    parallel -j ${thr} msa.sh -Xmx${mem} qin=33 in=${split}/{} out=${tmpout}/reverse_{}.sam literal="${reversep}" rcomp=t cutoff=${cut} && \
    touch ${logs}/done.${name}_${reversel}.${ts}
else
  echo "# reverse search already done"
fi

##########################################
# extract regions with BBMap cutprimers.sh

if [[ ! -f ${logs}/done.cutprimer.${name}_${forwardl}_${reversel}.${ts} ]]; then
echo "# extracting template sequences between primer matches"
find ${split} -type f -name "${name}_???.fq.gz" -printf '%P\n' |\
  sort -n |\
  parallel -j ${thr} cutprimers.sh -Xmx${mem} in=${split}/{} out=${tmpout}/{}_16s.fq sam1=${tmpout}/forward_{}.sam sam2=${tmpout}/reverse_{}.sam include=t fixjunk=t &&\
  touch ${logs}/done.cutprimer.${name}_${forwardl}_${reversel}.${ts}
fi

####################################################
# merge results and keep only reads longer than minl

if [[ ! -f ${logs}/done.merging.${name}_${forwardl}_${reversel}.${ts} ]]; then

  echo "# analysing read length distribution"
  minl="$(find ${tmpout} -type f -name "${name}_???.fq.gz_16s.fq" | sort -n |\
    xargs cat |\
    bioawk -c fastx '{if (length($seq)>1) print length($seq)}' |\
    Rscript -e 'unname(quantile (as.numeric (readLines ("stdin")), probs=c('${filterperc}')))' |\
    cut -d' ' -f2)"
  echo "# reads shorter than ${minl} nucleotides are removed during the filtering and merging step"
  echo "# you can disable filtering by changing the value of filterperc to 0"
  
  final="${name}_${forwardl}_${reversel}.${ts}.fq.gz"
  cat /dev/null > ${final}

  echo "# filtering and merging results to ${final}"
  find ${tmpout} -type f -name "${name}_???.fq.gz_16s.fq" | sort -n |\
    xargs cat |\
    bioawk -c fastx -v varlen="${minl}" '{if (length($seq)>=varlen) print "@"$name" "$comment"\n"$seq"\n+\n"$qual}' |\
    bgzip >> ${final} && \
    touch ${logs}/done.merging.${name}_${forwardl}_${reversel}.${ts}
else
  echo "# already all done, force redo by deleting the subfolders and or final merge file: ${final}"
fi

# return to normal
conda deactivate