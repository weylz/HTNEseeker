![HTNEseeker overview](HTNEseeker.overview.png)

----------
- [HTNEseeker](#htneseeker)
  - [Requirement](#requirement)
  - [Usage](#usage)
  - [Cite](#cite)
----------

# HTNEseeker
A framework for the identification of highly transcribed noncoding element (HTNE)

## Requirement

*To use the current release*

1. Linux (Such as Ubuntu 20.04 LTS);
2. Python 3.9.16;
3. R 4.2.3;
4. BEDTools suite 2.30.0;
5. Jim Kent's executable programms: http://hgdownload.cse.ucsc.edu/admin/exe/;


## Usage

*Try this program locally*

```shell
$ cd ~
$ git clone https://github.com/weylz/HTNEseeker.git


$ cd HTNEseeker
$ mkdir -p ./data/reference && mv ./test_data/blocklist.bed ./data/reference && mv ./test_data/hg19.chrom.sizes ./data/reference
$ mkdir -p ./data/brca && mv ./test_data/$bwfiles ./data/brca
$ mkdir -p ./data/sj/brca && mv ./test_data/$SJfiles ./data/sj/brca
$ # wget http://bioinfo.seu.edu.cn/data/HTNE/test_data.zip

$ chmod 744 ./HTNEseeker.sh
$ chmod 744 ./bin/*

$ ./bin/captureHTNE.sh --help

$ ./HTNEseeker.sh $sampleName $sampleNumber $cycleTime
# ./HTNEseeker.sh brca 7 30
```

## Cite
...

**HTNEseeker © weylz 2023. All rights reserved.**
