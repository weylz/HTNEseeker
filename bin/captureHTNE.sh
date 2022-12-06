#!/bin/bash
# File    :    2022/10/01 10:20:30
# Time    :    captureHTNE.sh
# Author  :    Wenyong Zhu
# Version :    1.0.0
# Desc    :    None


# $@-List of all parameters
Options=$@

# $#-The number of arguments added to the Shell
Optnum=$#

# $0-The file name of the Shell itself ($0 $Options)
function _usage(){
cat << EOF

Usage: 
    $0 <[options]>
Options:
    -H   --help                 Show help information 
    -G   --group_label=...      The label for samples group 
    -B   --mergedbedGraph=...   The bedGraph file of merged samples 
    -C   --chrom_size=...       genome chromosome sizes 
    -E   --blacklist=...        Bed file for exclusion region 
    -L   --list_bw_file=...     Tab-delimited file with two columns: sample ID and the path of bigwig file 
    -N   --length_min=...       minimal length of transcribed noncoding elements (default: 100)
    -S   --splicing_site=...    BED file for splicing site +/-10bp ($splicing_site)
EOF
}

# $?-Closing code of the last command to run (return value)
if [ $# = 0 ]; then echo -e "\n>>>>>>>> Invalid Syntax [missing required argument(s)] <<<<<<<<" && _usage && exit $?; fi

# ;;-Use the options in case and play the role of Terminator
while getopts 'G:B:C:E:L:N:S:-H' OPTION; do
    case "$OPTION" in
        H ) _usage                   ;;
        G ) group_label="$OPTARG"    ;;
        B ) mergedbedGraph="$OPTARG" ;;
        C ) chrom_size="$OPTARG"     ;;
        E ) blacklist="$OPTARG"      ;;
        L ) list_bw_file="$OPTARG"   ;;
        N ) length_min="$OPTARG"     ;;
        S ) splicing_site="$OPTARG"  ;;
        - ) [ $OPTIND -ge 1 ] && optind=$(expr $OPTIND - 1 ) || optind=$OPTIND
            eval OPTION="\$$optind"
            OPTARG=$(echo $OPTION | cut -d'=' -f2)
            OPTION=$(echo $OPTION | cut -d'=' -f1)
            if [ -z "$OPTARG" ]; then echo -e "\n>>>>>>>> Invalid Syntax <<<<<<<<" && _usage && exit $?; fi
            if [ "$OPTARG" == "$OPTION" ]; then echo -e "\n>>>>>>>> Invalid Syntax <<<<<<<<" && _usage && exit $?; fi
            case $OPTION in
                --help            ) _usage                   ;;   
                --group_label     ) group_label="$OPTARG"    ;;
                --mergedbedGraph  ) mergedbedGraph="$OPTARG" ;;
                --chrom_size      ) chrom_size="$OPTARG"     ;;
                --blacklist       ) blacklist="$OPTARG"   ;;
                --list_bw_file    ) list_bw_file="$OPTARG"   ;;
                --length_max      ) length_max="$OPTARG"     ;;
                --length_min      ) length_min="$OPTARG"     ;;
                --splicing_site   ) splicing_site="$OPTARG"  ;;
                * ) echo -e "\n>>>>>>>> Invalid Syntax [non-character object(s)] <<<<<<<<" && _usage && exit $?;;
            esac
        OPTIND=1
        shift
        ;;
        * )  echo -e "\n>>>>>>>> Invalid Syntax [non-character object(s)] <<<<<<<<" && _usage && exit $? ;;
    esac
done

# group_label
[ -z "$group_label" ] && echo -e "\n>>>>>>>> Invalid Syntax [missing required sample(s)] <<<<<<<<" && _usage && exit $?
[ -z "$blacklist" ] && blacklist=~/HTNEseeker/data/reference/blacklist.bed
[ -z "$length_min" ] && length_min=100
[ -z "$chrom_size" ] && chrom_size=~/HTNEseeker/data/reference/hg19.chrom.sizes
[ -z "$mergedbedGraph" ] && mergedbedGraph=trimmedmean.uniq.normalized.$group_label.bedGraph
[ -z "$list_bw_file" ] && list_bw_file=$group_label.bigwig.list
[ -z "$splicing_site" ] && splicing_site=
[ -d $group_label ] || echo -e "\n>>>>>>>> Invalid Syntax [missing required sample(s)] <<<<<<<<\n"
cd $group_label

#Exit if HTNE.bed already exists
[ -e HTNE.bed ] && echo "File HTNE.bed already exists. Exit!" && exit $?

echo -e "==================================================\n===============  HTNEseeker START!  ===============\n==================================================\n["`date`"]\nOptions:\n\tSample Group: $group_label\n\tblacklist File (.bed): $blacklist\n\tChromosome Size File (hg19/hg38): $chrom_size\n\tMinimum Length: $length_min\n\tSplicing Junction Sites File: $splicing_site\n"

echo "["`date`"] measuring transcriptional noise in background genomic regions ..."
# if not exist, then move sample file & generate $group_label.bigwig.list
[ -e $list_bw_file ] || for tmp_file in $(ls ./); do mkdir ${tmp_file%%.*} && mv $tmp_file ${tmp_file%%.*}; echo -e "$tmp_file\t$PWD/${tmp_file%%.*}/$tmp_file" >> $group_label.bigwig.list; done

# combine bigwig, using c of unionBedGraphs for samples from the same group
if [ ! -e $mergedbedGraph ]
then
    N=`cat $list_bw_file | wc -l`
    echo -e "\tNumber of Sample(s) = $N"

    # chromosome size
    # CHROM_SIZE=`curl -s http://hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/hg38.chrom.sizes | grep -v "_" | grep -v chrM | awk '{s+=$2}END{print s}'`
    # CHROM_SIZE=`curl -s http://hgdownload.cse.ucsc.edu/goldenPath/hg19/bigZips/hg19.chrom.sizes | grep -v "_" | grep -v chrM | awk '{s+=$2}END{print s}'`
    CHROM_SIZE=3095677412
    echo -e "\tchromosome size = $CHROM_SIZE <--> [Note: hg19 = 3095677412; hg38 = 3088269832]"

    # if [ "$N" == "1" ]
    # then
    #     awk -v CHROM_SIZE=$CHROM_SIZE '{OFS="\t";S+=$4*($3-$2); if(id!=$4 || e!=$2 || chr!=$1) {if(chr!="") print chr,s,e,id; chr=$1;s=$2;e=$3;id=$4;} else {e=$3;}}END{print chr,s,e,id; TOTAL=CHROM_SIZE; bc=S/TOTAL;print "#basalCoverage="bc, "#"S"/"TOTAL;}' `sed 's/bw/bedGraph/g' $list_bw_file` > trimmedmean.uniq.normalized.$group_label.bedGraph
    #     ln -fs `cut -f2 $list_bw_file` trimmedmean.uniq.normalized.$group_label.bw
    #     exit
    # fi

    echo "["`date`"] computing trimmed mean of bedGraph ..."
    # echo "["`date`"] computing trimmed mean of bedGraph (using up to $N samples randomly picked)"

    # using ucsc-bigWigMerge to add signal values of multiple bigWigs together into a single output bedGraph
    # cut -f2 $list_bw_file | sort --random-sort --random-source=$list_bw_file | head -n$N > $list_bw_file.top$N
    # N=`cat $list_bw_file.top$N | wc -l`
    cut -f2 $list_bw_file | sort --random-sort --random-source=$list_bw_file > $list_bw_file.PATH
    N=`cat $list_bw_file.PATH | wc -l`

    # merge, sort, and add the last line, and also convert sum to mean (LC_ALL=C is to remove all localized settings so that the command executes correctly; n-numeric)
    [ -e mean.uniq.normalized.$group_label.bedGraph ] || bigWigMerge -inList $list_bw_file.PATH stdout | LC_ALL=C sort -S 10G -T /tmp -k1,1 -k2,2n | awk -v N=$N -v CHROM_SIZE=$CHROM_SIZE '{OFS="\t"; $4=$4/N; S+=$4*($3-$2); if(id!=$4 || e!=$2 || chr!=$1) {if(chr!="") print chr,s,e,id; chr=$1; s=$2; e=$3; id=$4;} else {e=$3;}}END{print chr,s,e,id; TOTAL=CHROM_SIZE; bc=S/TOTAL; print "#basalCoverage="bc, "#"S"/"TOTAL;}' > mean.uniq.normalized.$group_label.bedGraph
    sed -e '/#/d;/GL/d;/MT/d' mean.uniq.normalized.$group_label.bedGraph > trimmedmean.uniq.normalized.$group_label.bedGraph
    sed -i 's/^/chr&/g' trimmedmean.uniq.normalized.$group_label.bedGraph

    echo "["`date`"] translating bedGraph file to bigwig file ..."
    bedGraphToBigWig trimmedmean.uniq.normalized.$group_label.bedGraph $chrom_size trimmedmean.uniq.normalized.$group_label.bw
    mergedbedGraph=trimmedmean.uniq.normalized.$group_label.bedGraph
fi

# ============================================================= -seed -l -n
# RNAseq signal distribution in the background region
echo "["`date`"] measuring RNAseq signal distribution in the background region ..."
[ -e transcriptional.noise.rpm.txt ] || bedtools random -seed 3 -g $chrom_size -l 1 -n 1000000 | sortBed | intersectBed -a - -b $blacklist -v -sorted | intersectBed -a $mergedbedGraph -b - -sorted -u | cut -f4 > transcriptional.noise.rpm.txt
~/HTNEseeker/bin/fitRTS.R transcriptional.noise.rpm.txt
distp=`tail -n1 transcriptional.noise.rpm.pvalues.txt`  # distribution

echo "["`date`"] any regions with higher RNAseq density than the average coverage ..."
averageCoverage=`sed '/chr\|#/!d' mean.uniq.normalized.$group_label.bedGraph | tail -n1 | cut -f2 -d'=' | cut -f1`
echo -e "\tAverage Coverage = $averageCoverage"
awk -v avgc=$averageCoverage '{OFS="\t"; if($4>=avgc) print $1,$2,$3,$4}' $mergedbedGraph | mergeBed -c 4 -o max > HTNE.tmp1

# ============================================================= -d
echo "["`date`"] summit RPM at significiant level (p<=0.05) ..."
echo -e "\tSignificiant Level of RPM = $distp"
awk -v D=$distp '{OFS="\t"; if($4>=D) print $1,$2,$3,$4}' HTNE.tmp1 | mergeBed -d $length_min -c 4 -o max > HTNE.tmp2

echo "["`date`"] no overlap with any known transcibed regions ..."
# bedtools subtract -a HTNE.tmp2 -b $blacklist -f 0.5 > HTNE.tmp3
bedtools subtract -a HTNE.tmp2 -b $blacklist > HTNE.tmp3

echo "["`date`"] at least "$length_min"bp in length ..."
awk -v len_min=$length_min '{OFS="\t"; if(($3-$2)>=len_min) print $1,$2,$3,$1"_"$2"_"$3}' HTNE.tmp3 > HTNE.tmp4

echo "["`date`"] don't contain any splicing sites "
intersectBed -a HTNE.tmp4 -b $splicing_site -v > HTNE.tmp5

echo "["`date`"] bonferroni and FDR corrected p<=0.05 ..."
# 1.create random background regions (same number and same length distribution as HTNEs) and calculate their signals
echo -e "\t** creating random background regions and calculating their signals ...\n\t\tProcessing ...\n"
while read sample bigwigFile
do
    bedtools shuffle -seed 123 -excl $blacklist -i HTNE.tmp5 -noOverlapping -g $chrom_size | awk -v OFS="\t" '$4=$1"_"$2"_"$3' | bigWigAverageOverBed $bigwigFile stdin stdout | cut -f1,5 > $bigwigFile.randomBackground
    bigWigAverageOverBed $bigwigFile HTNE.tmp5 stdout | cut -f1,5 | sort -k1,1 > $bigwigFile.HTNE.meanRPM
done < $list_bw_file
# 2.compute p-value for each HTNE candidate in each sample's random background, then test the number of samples with p<0.05 with the binomial test, adjust p-value from binomial test with bonferroni and FDR correction
echo -e "\n\t** computing p-value for each HTNE candidate in each sample's random background, \n\t   testing the number of samples with p<0.05 with the binomial test, \n\t   adjusting p-value from binomial test with bonferroni and FDR correction"
~/HTNEseeker/bin/calEXP.R $group_label $list_bw_file   # output are HTNE.tmp5.meanRPM.xls, HTNE.tmp5.pvalues.xls, and HTNE.tmp5.pvalues.adjusted.xls
# 3.Select HTNE with adjusted p <= 0.05:
echo -e "\t** selecting HTNE with adjusted p <= 0.05 ..."
# bonferroni for the major groups
awk '{OFS="\t"; split($1,a,"_"); if($1~/^chr/) {if($4<=0.05) print a[1],a[2],a[3],$1}}' HTNE.tmp5.pvalues.adjusted.xls | sort > HTNE.bonferroni.bed
# FDR for minor cell types
# awk '{OFS="\t"; split($1,a,"_"); if($1~/^chr/) {if($5<=0.05) print a[1],a[2],a[3],$1}}' HTNE.tmp5.pvalues.adjusted.xls | sort > HTNE.FDR.bed

# =================
# loci.txt required for fasteQTL
awk 'BEGIN{OFS="\t"; print "id","chr","s1","s2";}{print $4,$1,$2,$3;}' HTNE.bonferroni.bed > HTNE.loci.bonferroni.txt
# awk 'BEGIN{OFS="\t"; print "id","chr","s1","s2";}{print $4,$1,$2,$3;}' HTNE.FDR.bed > HTNE.loci.FDR.txt

# meanRPM
paste HTNE.tmp5.pvalues.adjusted.xls HTNE.tmp5.meanRPM.xls | awk 'NR==1 || $4<=0.05' | cut -f6 - > HTNE.meanRPM.bonferroni.xls
# paste HTNE.tmp5.pvalues.adjusted.xls HTNE.tmp5.meanRPM.xls | awk 'NR==1 || $5<=0.05' | cut -f6 - > HTNE.meanRPM.FDR.xls

sortBed -i HTNE.bonferroni.bed > ../HTNE.$group_label.bed
# sortBed -i HTNE.FDR.bed > ../$group_label.FDR.bed

echo "["`date`"] Done!"

echo -e "==================================================\n================  HTNEseeker END!  ================\n=================================================="
