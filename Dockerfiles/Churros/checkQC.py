#! /usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys
import pandas as pd
import re

if len(sys.argv) != 3:
    print("Usage: checkQC.py <stats file> <samplepairlist.txt>")
    print("    <stats file>: Path to the stass TSV file (e.g., 'Churros_result/hg38/churros.QCstats.tsv').")
    print("    samplepairlist.txt: The sample pair list used in Churros.")
    sys.exit(1)

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


column_name = data.columns.get_loc("Sample")
column_maprate = data.columns.get_loc("Mapped 1 time") + 1
column_uniquereads = data.columns.get_loc("Nonredundant")
column_complexity = data.columns.get_loc("Complexity for10M")
column_genomecov = data.columns.get_loc("Genome coverage")

if "GC summit" in data.columns:
    column_GC = data.columns.get_loc("GC summit")

column_nsc = data.columns.get_loc("NSC")
column_bu = data.columns.get_loc("Background uniformity")

for index, row in data.iterrows():
    label = row[column_name]

    # mapping rate
    mapratio = row[column_maprate]
    if mapratio < 60.0:
        print(f"Warning: {label} has a unique mapping rate {mapratio}%, which is less than 60.0%")

    match = re.search(r'(\d+)', str(row[column_uniquereads]))
    if match:
        uniquereads = int(match.group(1))
        if uniquereads < 10000000:
            print(f"Warning: {label} has {uniquereads} nonredundant reads, which is less than 10,000,000")

    complexity = row[column_complexity]
    if isinstance(complexity, str):
        print(f"Warning: {label} has too few mapped reads to compute a library complexity: {complexity}")
    elif complexity < 0.8 and complexity > 0:
        print(f"Warning: {label} has a complexity {complexity}, which is less than 0.8")

    genomecov = row[column_genomecov]
    if genomecov < 0.6:
        print(f"Warning: {label} has a genome coverage {genomecov}, which is less than 0.6")

    if "GC summit" in data.columns:
        gc = row[column_GC]
        if gc > 60:
            print(f"Warning: {label} has a {gc}% GC content, which is more than 60%")

    nsc = row[column_nsc]
    if label in data_dict:
        if "sharp" in data_dict[label] and nsc < 3.0:
           print(f"Warning: {label} has SSP-NSC < {nsc}, which is less than 3.0 (threshold for sharp peaks)")
        elif "broad" in data_dict[label] and nsc < 1.5:
           print(f"Warning: {label} has SSP-NSC < {nsc}, which is less than 1.5 (threshold for broad peaks)")

    backcomp = row[column_bu]
    if backcomp < 0.8:
        print(f"Warning: {label} has a background complexity {backcomp}, which is less than 0.8")