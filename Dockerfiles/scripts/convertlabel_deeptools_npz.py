#! /usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import numpy as np

inputfile = sys.argv[1]
outputfile = sys.argv[2]

npz = np.load(inputfile)
labels = npz['labels']
for i, label in enumerate(labels):
    label_renamed = str(label).replace('-bowtie2-hg38-raw-mpbl-GR.100.bw','')
    labels[i] = label_renamed.encode('unicode-escape')

np.savez(outputfile, matrix=npz['matrix'], labels=labels)
