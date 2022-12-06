#!/bin/bash
# File    :    2022/10/01 10:20:30
# Time    :    sjCombination.sh
# Author  :    Wenyong Zhu
# Version :    1.0.0
# Desc    :    None


echo 'sj combination starting ...'
python ~/HTNEseeker/bin/sjCombination.py $1/sj/brca/

echo 'combining splice junctions ...'
cd $1/sj/brca/
cat *bed | sortBed | uniq > ../brca.sj.flanking20nt.bed && rm -rf ./*bed

cd $1

echo 'sj combination Finished.'
