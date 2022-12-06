#!/bin/bash

echo "Starting ... "

export PATH=~/HTNEseeker/bin:$PATH

# Absolute path required
sampleName=$1
sampleNum=$2
cycle_time=$3
work_dir=~/HTNEseeker/workspace/
data_dir=~/HTNEseeker/data/

sampleNum=`echo "$sampleNum * 0.7" | bc`
sampleNum=`printf "%.0f" $sampleNum`
# rm -rf $work_dir
[ -e $work_dir ] || mkdir $work_dir

echo "[ cycle time:" $cycle_time "]"
python ~/HTNEseeker/bin/randomSelection.py $work_dir $data_dir $cycle_time $sampleName $sampleNum

echo "Moving Files ..."
cd $work_dir
[ -e RandomizedTrials_$cycle_time ] || mkdir RandomizedTrials_$cycle_time
cd RandomizedTrials_$cycle_time
mv ../random_trial_* ./ 
mv ../HTNE.R* ./
    
echo "Intervene ..."
cd $work_dir
trialsIntervene.sh $work_dir $cycle_time
echo "Intervene Finished."

cd $work_dir
wc -l RepeatedTrial/HTNE.specific_* | sort -n -r | grep -v total |awk '{print $1}' > stableDetection.txt
Rscript ~/HTNEseeker/bin/stableDetection.R
rm -rf stableDetection.txt

cd ~/HTNEseeker/

echo "All Finished."
