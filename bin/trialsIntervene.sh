#!/bin/bash
# File    :    2022/10/01 10:20:30
# Time    :    intervene.sh
# Author  :    Wenyong Zhu
# Version :    0.0.1
# Desc    :    None


echo "intervene starting ..."

list_sample=()
for ((i=0; i<$2; i++))
do
    
    [ -e $1/RepeatedTrial ] || mkdir $1/RepeatedTrial
    list_sample+=(HTNE.R$i.bed)
    echo "===================================="
    # echo ${#list_sample[*]}, ${list_sample[*]}
    [ -e $1/RepeatedTrial/rt_$i ] || mkdir $1/RepeatedTrial/rt_$i
    
    for ((j=0; j<${#list_sample[*]}; j++))
    do
        cp $1/RandomizedTrials_$2/HTNE.R$j.bed $1/RepeatedTrial/rt_$i
        sed -i '/chrY/d' $1/RepeatedTrial/rt_$i/HTNE.R$j.bed
    done
    
    countNum=$[$i+1]
    echo "Repeated Trial : $countNum Starting ..."
    cd $1/RepeatedTrial/rt_$i
    if [ "$i" == "0" ]
    then
        cp HTNE.R0.bed HTNE.specific_$countNum.bed
    else
        multiIntersectBed -i HTNE.R* | awk -v countNum=$countNum '{if($4==countNum) print $0}' | intersectBed -a stdin -b HTNE.R* -f 0.7 -r | cut -f1-3 | sort -u -k1,1V -k2,2n > HTNE.specific_$countNum.bed
    fi
    cp $1/RepeatedTrial/rt_$i/HTNE.specific_$countNum.bed $1/RepeatedTrial/

done
echo "===================================="
echo "intervene finished."
