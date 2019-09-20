## Summary

The gDNA **Zymo-PromethION-EVEN-BB-SN** reads data from [the mockcommunity](https://github.com/LomanLab/mockcommunity) was used as input to extract either the **'full-length'** 16S amplicon corresponding to the PCR **27F-U1492R** <sup id="a1">[1](#f1)</sup> or the shorter **V3V4** amplicon corresponding to the primer combination **337F-805R** <sup id="a1">[1](#f1)</sup>.

[![16S_regions](pictures/16S_regions.png)](https://teachthemicrobiome.weebly.com/sequencing-the-microbiome.html)

The extracted reads were submitted to the ONT [16S Epi2Me pipeline](https://nanoporetech.com/nanopore-sequencing-data-analysis) to be classified and allow direct comparison of the two amplicon options at different levels.

## Results

### **27F-U1492R** in-silico amplicon

* Epi2ME **genus** results for the **27F-U1492R** in-silico amplicon: [(link)](https://epi2me.nanoporetech.com/workflow_instance/214013)
   * 27F: "AGAGTTTGATCMTGGCTCAG"
   * 1492Rw: "CGGTWACCTTGTTACGACTT"
   * [epi2me results](https://github.com/Nucleomics-VIB/InSilico_PCR/raw/master/results/27F-U1492R_214013_classification_16s_barcode-v1.csv)

 ![27F-U1492R_genus](pictures/27F-U1492R_reads.png)

 ![27F-U1492R_genus](pictures/27F-U1492R_genus.png)

### **337F-805R** in-silico amplicon

* Epi2ME **genus** results for the **337F-805R** in-silico amplicon: [(link)](https://epi2me.nanoporetech.com/workflow_instance/214508)
   * 337F: "GACTCCTACGGGAGGCWGCAG"
   * 805R: "GACTACHVGGGTATCTAATCC"
   * [epi2me results](https://github.com/Nucleomics-VIB/InSilico_PCR/raw/master/results/337F-805R_214508_classification_16s_barcode-v1.csv)

 ![337F-805R_genus](pictures/337F-805R_reads.png)

 ![337F-805R_genus](pictures/337F-805R_genus.png)

### **515FB-U1492R** in-silico amplicon

* Epi2ME **genus** results for the **515FB-U1492R** in-silico amplicon: [(link)](https://epi2me.nanoporetech.com/workflow_instance/214514)
   * 515FB: "GTGYCAGCMGCCGCGGTAA"
   * U1492Rw: "CGGTWACCTTGTTACGACTT"
   * [epi2me results](https://github.com/Nucleomics-VIB/InSilico_PCR/raw/master/results/515FB-U1492Rw_214514_classification_16s_barcode-v1.csv)

 ![515FB-U1492Rw_genus](pictures/515FB-U1492Rw_reads.png)

 ![515FB-U1492Rw_genus](pictures/515FB-U1492Rw_genus.png)

## References
<b id="f1">1</b> 16S ribosomal RNA [Link](https://en.wikipedia.org/wiki/16S_ribosomal_RNA). [↩](#a1)
