#!/usr/bin/env python
# -*- coding: utf-8 -*-
'''
@File     :  randomSelection.py
@Time     :  2022/10/01 10:20:30
@Author   :  Wenyong Zhu
@Version  :  1.0.0
@Desc     :  None
'''


import os, random, subprocess, sys

dict = {sys.argv[4]:int(sys.argv[5])}
for time in range(int(sys.argv[3])):
    subprocess.call('cd ' + sys.argv[1] + ' && rm -rf brca sj && mkdir brca && mkdir sj && mkdir sj/brca', shell = True)
    random.seed(time)
    for key in dict:
        for root, dirs, files in os.walk(sys.argv[2] + key):
            continue
        tmp = random.sample(files, dict[key])
        print(key)
        print(*tmp, sep = ' || ')
        for i in range(len(tmp)):
            sample_name = tmp[i].split('.')[0]
            script = 'cp ' + sys.argv[2] + key + '/' + sample_name + '.bw ' + sys.argv[1] + '/brca && cp ' + sys.argv[2] + '/sj/' + key + '/' + sample_name + '_SJ.out.tab ' + sys.argv[1] + '/sj/brca'
            subprocess.call(script, shell = True)

    subprocess.call('sjCombination.sh ' + sys.argv[1], shell = True)
    subprocess.call('cd ' + sys.argv[1] + ' && captureHTNE.sh -G brca -S ' + sys.argv[1] + '/sj/brca.sj.flanking20nt.bed', shell = True)
    subprocess.call('cd ' + sys.argv[1] + ' && mkdir random_trial_'+ str(time) + ' && cd ./random_trial_'+ str(time) + ' && mv ../brca ./ && mv ../sj ./ && mv ../HTNE.brca.bed ./ && cp ./HTNE.brca.bed ../HTNE.R' + str(time) + '.bed', shell = True)

