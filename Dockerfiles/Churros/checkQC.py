#! /usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys
import pandas as pd
import re

file_path = sys.argv[1]
data = pd.read_csv(file_path, sep='\t')

samplepairlist = sys.argv[2]
data_dict = {}
with open(samplepairlist, 'r') as file:
    for line in file:
        columns = line.strip().split(',')
        key = columns[0]
        value = columns[3]
        data_dict[key] = value

for index, row in data.iterrows():
    label = row[1]
    mapratio = row[4]
    if mapratio < 60.0:
        print(f"Warning: {label} has a unique mapping rate {mapratio}%, which is less than 60.0%")

    match = re.search(r'(\d+)', str(row[11]))
    if match:
        uniquereads = int(match.group(1))
        if uniquereads < 10000000:
            print(f"Warning: {label} has {uniquereads} nonredundant reads, which is less than 10,000,000")

    complexity = row[13]
    if complexity < 0.8:
        print(f"Warning: {label} has a complexity {complexity}, which is less than 0.8")

    genomecov = row[16]
    if genomecov < 0.6:
        print(f"Warning: {label} has a genome coverage {genomecov}, which is less than 0.6")

    gc = row[19]
    if gc > 60:
        print(f"Warning: {label} has a {gc}% GC content, which is more than 60%")

    nsc = row[22]
    if label in data_dict:
        if "sharp" in data_dict[label] and nsc < 3.0:
           print(f"Warning: {label} has SSP-NSC < {nsc}, which is less than 3.0 (threshold for sharp peaks)")
        elif "broad" in data_dict[label] and nsc < 1.5:
           print(f"Warning: {label} has SSP-NSC < {nsc}, which is less than 1.5 (threshold for broad peaks)")

    backcomp = row[25]
    if backcomp < 0.8:
        print(f"Warning: {label} has a background complexity {backcomp}, which is less than 0.8")