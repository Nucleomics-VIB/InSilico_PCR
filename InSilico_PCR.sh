#!/bin/bash

# script: InSilico_PCR.sh

# activate conda to get required tools
# req: bbmap
# req bioawk

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
host=${2:-"https://nanopore.s3.climb.ac.uk"}

# download once only
if [[ ! -f ${infile} ]]; then
  echo "# downloading ${infile} (may take some time!)"
  wget ${host}/${infile}
else
  echo "# ${infile} was already downloaded from ${host}"
fi

# speed-up
thr=48
pigt=8
mem="8g"

# extract reads corresponding to the 16S PCR
forwardp="AGAGTTTGATCMTGGCTCAG"
reversep="CGGTWACCTTGTTACGACTT"

# be stringent to avoid noisy reads
cut=0.8

# split in 500k read bins and zip
lines=2000000

# minimum expected amplicon length
minl=1000

# result folders
split="split_data"
mkdir -p ${split}

tmpout="bbmap_out"
mkdir -p ${tmpout}

# split large file into chunks for parallel
if [[ ! -f ${split}/done.splitting ]]; then
  echo "# splitting the data in multiple smaller files and compressing (may take some time!)"
  zcat ${infile} |\
    split --numeric-suffixes --additional-suffix=.fq -a 3 -l ${lines} - ${split}/${infile%%\.fq\.gz}_ && \
    find ${split} -type f -name *_???.fq | parallel -j ${pigt} pigz -p ${pigt} {} && \
    touch  ${split}/done.splitting
else
  echo "# splitting already done"
fi

#################################
# run in BBMap msa.sh in parallel

# find forward primer
if [[ ! -f ${tmpout}/done.forward ]]; then
  echo "# searching for forward primer sequence: ${forwardp} in all files"
  find ${split} -type f -name "${infile%%\.fq\.gz}_???.fq.gz" -printf '%P\n' |\
    sort -n |\
    parallel -j ${thr} msa.sh -Xmx${mem} qin=33 in=${split}/{} out=${tmpout}/forward_{}.sam literal="${forwardp}" rcomp=t cutoff=${cut} && \
    touch ${tmpout}/done.forward
else
  echo "# forward search already done"
fi

# find reverse primer
if [[ ! -f ${tmpout}/done.reverse ]]; then
  echo "# searching for reverse primer sequence: ${reversep} in all files"
  find ${split} -type f -name "${infile%%\.fq\.gz}_???.fq.gz" -printf '%P\n' |\
    sort -n |\
    parallel -j ${thr} msa.sh -Xmx${mem} qin=33 in=${split}/{} out=${tmpout}/reverse_{}.sam literal="${reversep}" rcomp=t cutoff=${cut} && \
    touch ${tmpout}/done.reverse
else
  echo "# reverse search already done"
fi

# extract regions with BBMap cutprimers.sh
if [[ ! -f ${tmpout}/done.cutprimer ]]; then
echo "# extracting template sequences between primer matches"
find ${split} -type f -name "${infile%%\.fq\.gz}_???.fq.gz" -printf '%P\n' |\
  sort -n |\
  parallel -j ${thr} cutprimers.sh -Xmx${mem} in=${split}/{} out=${tmpout}/{}_16s.fq sam1=${tmpout}/forward_{}.sam sam2=${tmpout}/reverse_{}.sam include=t fixjunk=t &&\
  touch ${tmpout}/done.cutprimer
fi

####################################################
# merge results and keep only reads longer than minl

if [[ ! -f done.all ]]; then
  final="${infile%%\.fq\.gz}_16S.fq.gz"
  cat /dev/null > ${final}

  echo "# filtering and merging results to ${final}"
  find ${tmpout} -type f -name "${infile%%\.fq\.gz}_???.fq.gz_16s.fq" -printf '%P\n' |\
    xargs cat |\
    bioawk -c fastx -v varlen="${minl}" '{if (length($seq)>=varlen) print "@"$name" "$comment"\n"$seq"\n+\n"$qual}' |\
    bgzip >> ${final} && \
    touch done.all
else
  echo "# already all done, force redo by deleting the subfolders and or final merge file: ${final}"
fi

# cleanup
# rm -rf ${split}
# rm -rf ${tmpout}

# return to normal
conda deactivate
