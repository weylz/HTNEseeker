#!/usr/bin/env python
# -*- coding: utf-8 -*-
'''
@File     :  sjCombination.py
@Time     :  2022/10/01 10:20:30
@Author   :  Wenyong Zhu
@Version  :  1.0.0
@Desc     :  None
'''


import os, sys

chrom_name_1 = ['chr1', 'chr2', 'chr3', 'chr4', 'chr5', 'chr6', 'chr7', 'chr8', 'chr9', 'chr10', 'chr11', 'chr12', 'chr13', 'chr14', 'chr15', 'chr16', 'chr17', 'chr18', 'chr19', 'chr20', 'chr21', 'chr22', 'chrX']
chrom_name_2 = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', 'X']
c_num = 0
for root, dirs, files in os.walk(sys.argv[1], topdown=False):
    continue
for i in range(len(files)):
    if 'SJ.out.tab' in files[i]:
        filename = files[i].split('_')[0]
        c_num = c_num + 1
        print('[ ' + str(c_num) + ' / ' + str(len(files)) + ' ] ' + filename + ' ...')
        rlt = open(sys.argv[1] + filename + '.bed', 'w')
        with open(sys.argv[1] + files[i], 'r') as f:
            f = f.readlines()
            for j in range(len(f)):
                f[j] = f[j].strip().split('\t')
                if f[j][0] in chrom_name_1:
                    if int(f[j][1]) <= 10:
                        rlt.writelines(f[j][0] + '\t' + 1 + '\t' + str(int(f[j][1])+10))
                    else:
                        rlt.writelines(f[j][0] + '\t' + str(int(f[j][1])-10) + '\t' + str(int(f[j][1])+10) + '\n')
                    if int(f[j][2]) <= 10:
                        rlt.writelines(f[j][0] + '\t' + 1 + '\t' + str(int(f[j][2])+10) + '\n')
                    else:
                        rlt.writelines(f[j][0] + '\t' + str(int(f[j][2])-10) + '\t' + str(int(f[j][2])+10) + '\n')
                elif f[j][0] in chrom_name_2:
                    if int(f[j][1]) <= 10:
                        rlt.writelines('chr' + f[j][0] + '\t' + 1 + '\t' + str(int(f[j][1])+10))
                    else:
                        rlt.writelines('chr' + f[j][0] + '\t' + str(int(f[j][1])-10) + '\t' + str(int(f[j][1])+10) + '\n')
                    if int(f[j][2]) <= 10:
                        rlt.writelines('chr' + f[j][0] + '\t' + 1 + '\t' + str(int(f[j][2])+10) + '\n')
                    else:
                        rlt.writelines('chr' + f[j][0] + '\t' + str(int(f[j][2])-10) + '\t' + str(int(f[j][2])+10) + '\n')
        rlt.close()
