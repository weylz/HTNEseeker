![HTNEseeker overview](HTNEseeker.overview.png)


----------
- <font face = "Times New Roman" size = 4> ***[HTNEseeker](#htneseeker)*** </font>
  - <font face = "Times New Roman" size = 3> ***[Requirement](#requirement)*** </font>
  - <font face = "Times New Roman" size = 3> ***[Usage](#usage)*** </font>
  - <font face = "Times New Roman" size = 3> ***[Citation](#citation)*** </font>
----------

# HTNEseeker
<font face = "Times New Roman" size = 5> **A framework for the identification of highly transcribed noncoding element (HTNE)** </font>

## Requirement

<font face = "Times New Roman" size = 4> ***To use the current release*** </font>
<font face = "Times New Roman" size = 3>
1. Linux (such as Ubuntu 20.04 LTS);
2. Python 3.9.16;
3. R 4.2.3;
4. BEDTools suite 2.30.0;
5. Jim Kent's executable programms: http://hgdownload.cse.ucsc.edu/admin/exe/;
</font>

## Usage
<font face = "Times New Roman" size = 4> ***Try this program locally*** </font>

```shell
$ cd ~
$ git clone https://github.com/weylz/HTNEseeker.git

$ cd HTNEseeker
$ cd test && unzip '*.zip' && cd ..
$ mkdir -p ./data/reference && mv ./test/blocklist.bed ./data/reference && mv ./test_data/hg19.chrom.sizes ./data/reference
$ mkdir -p ./data/brca && mv ./test/*.bw ./data/brca
$ mkdir -p ./data/sj/brca && mv ./test/*_SJ.out.tab ./data/sj/brca

$ chmod 744 ./*.sh ./bin/*

$ ./bin/captureHTNE.sh --help
  # Usage:
  #     ./bin/captureHTNE.sh <[options]>
  # Options:
  #     -H   --help                 Show help information
  #     -G   --group_label=...      The label for samples group
  #     -B   --mergedbedGraph=...   The bedGraph file of merged samples
  #     -C   --chrom_size=...       genome chromosome sizes
  #     -E   --blocklist=...        Bed file for exclusion region
  #     -L   --list_bw_file=...     Tab-delimited file with two columns: sample ID and the path of bigwig file
  #     -N   --length_min=...       minimal length of transcribed noncoding elements (default: 100)
  #     -S   --splicing_site=...    BED file for splicing site +/-10bp ()

# ./HTNEseeker.sh $sampleName $sampleNumber $cycleTime
$ ./HTNEseeker.sh brca 7 30
```

## Citation
<font face = "Times New Roman" size = 3> Wenyong Zhu et al. Delineating highly transcribed noncoding elements landscape in breast cancer. *Computational and Structural Biotechnology Journal*. 2023;21:4432-4445 [link](https://doi.org/10.1016/j.csbj.2023.09.009) </font>

<font face = "Times New Roman" size = 2> ***Copyright © 2023 Wenyong Zhu et al. All Rights Reserved.*** </font>
