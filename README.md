[(Nucleomics-VIB)](https://github.com/Nucleomics-VIB)

InSilico PCR
==========

This script aims at extracting sequences likely representing amplicon reads from a larger context longread set (gDNA reads or larger amplicon)
The motivation behind this analysis was to simulate 16S long amplicon sequencing on ONT platform from data obtained from the 
The data can be obtained from the **https://github.com/LomanLab/mockcommunity** site as a large Promethion fastq archive but any other ONT or Pacbio fastq data can be used with this code.

== Data Availability (reproduced from https://github.com/LomanLab/mockcommunity/edit/master/README.md)

|Name|Reads (M)|Yield (G)|FASTQ|Run Folder|Restarts|FAST5|
|:--|:--|:--|:--|:--|:--|:--|
|Zymo-PromethION-LOG-BB-SN|35.1|148|[fastq.gz](https://nanopore.s3.climb.ac.uk/Zymo-PromethION-LOG-BB-SN.fq.gz)|[64h run](https://nanopore.s3.climb.ac.uk/Zymo-PromethION-LOG-BB-SN_basecalls.tar.gz)|[restarts](https://nanopore.s3.climb.ac.uk/Zymo-PromethION-LOG-BB-SN-restarts_basecalls.tar.gz)|[download.sh](https://gist.github.com/SamStudio8/3ebbbd04dd8db557a3e8bdcedc875ee6), [restarts.tar](https://nanopore.s3.climb.ac.uk/Zymo-PromethION-LOG-BB-SN-restarts_signal.tar)|
|Zymo-PromethION-EVEN-BB-SN|36.5|146|[fastq.gz](https://nanopore.s3.climb.ac.uk/Zymo-PromethION-EVEN-BB-SN.fq.gz)|[64h run](https://nanopore.s3.climb.ac.uk/Zymo-PromethION-EVEN-BB-SN_basecalls.tar.gz)|[restarts](https://nanopore.s3.climb.ac.uk/Zymo-PromethION-EVEN-BB-SN-restarts_basecalls.tar.gz)|[download.sh](https://gist.github.com/SamStudio8/3ebbbd04dd8db557a3e8bdcedc875ee6), [restarts.tar](https://nanopore.s3.climb.ac.uk/Zymo-PromethION-EVEN-BB-SN-restarts_signal.tar)|
|Zymo-GridION-LOG-BB-SN|3.7|16|[fastq.gz](https://nanopore.s3.climb.ac.uk/Zymo-GridION-LOG-BB-SN.fq.gz)|[48h run](https://nanopore.s3.climb.ac.uk/Zymo-GridION-LOG-BB-SN_basecalled.tgz)|n/a|[signal.tar](https://nanopore.s3.climb.ac.uk/Zymo-GridION-LOG-BB-SN_signal.tar)|
|Zymo-GridION-EVEN-BB-SN|3.5|14|[fastq.gz](https://nanopore.s3.climb.ac.uk/Zymo-GridION-EVEN-BB-SN.fq.gz)|[48h run](https://nanopore.s3.climb.ac.uk/Zymo-GridION-EVEN-BB-SN_basecalled.tgz)|n/a|[signal.tar](https://nanopore.s3.climb.ac.uk/Zymo-GridION-EVEN-BB-SN_signal.tar)|

== method

The method used to extract sequences between primers was developed by Brian Bushnell and explained [here](https://www.biostars.org/p/216039/#216054)

# set names and numeric limits in the config.yaml file (otherwise it will run my initial workflow)
# split the data in small chunks for speed-up using parallel
# search forward primer in all chunks using BBMap msa.sh
# search reverse primer in all chunks using BBMap msa.sh
# extract 'matching' regions using BBMAp cutprimers.sh 
# merge all results and keep only regions larger than a certain size (could be changed easily to size range)

== future plans ==

This code should and will be changed to a **snakemake** pipeline in order to be more portable. The yaml fiel is the first step towards this transition.

<hr>

<h4>Please send comments and feedback to <a href="mailto:nucleomics.bioinformatics@vib.be">nucleomics.bioinformatics@vib.be</a></h4>

<hr>

![Creative Commons License](http://i.creativecommons.org/l/by-sa/3.0/88x31.png?raw=true)

This work is licensed under a [Creative Commons Attribution-ShareAlike 3.0 Unported License](http://creativecommons.org/licenses/by-sa/3.0/).
