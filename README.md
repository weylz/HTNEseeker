# HTNEseeker
 A framework for the identification of highly transcribed noncoding element (HTNE)

Requirement
--------------------
1. Python 3.7 or later; 
2. R 4.0 or later;
3. The BEDTools suite 2.30.0 or later;
4. Jim Kent's executable programms: http://hgdownload.cse.ucsc.edu/admin/exe/;


Usage
--------------------
```shell
cd ~
git clone https://github.com/weylz/HTNEseeker.git

cd HTNEseeker
mkdir -p ./data/reference && mv blacklist.bed ./data/reference && mv hg19.chrom.sizes ./data/reference
mkdir -p ./data/brca && mv $bwfiles ./data/brca
mkdir -p ./data/sj/brca && mv $SJfiles ./data/sj/brca

chmod 744 HTNE
chmod 744 ./bin/*

./HTNEseeker.sh $sampleName $sampleNumber $cycleTime

# e.g. ./HTNEseeker.sh brca 10 20
```

Folder structure
--------------------
cmd