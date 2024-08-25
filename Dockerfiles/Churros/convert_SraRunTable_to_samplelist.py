#!/bin/env python
# Copyright(c) Ryuichiro Nakato <rnakato@iqb.u-tokyo.ac.jp>
# All rights reserved.

import pandas as pd
import sys

def parse_SraRunTable(file_path, line_to_extract):
    df = pd.read_csv(file_path)
    df['Run'] = 'fastq/' + df.iloc[:, 0].astype(str) + '.fastq.gz'
    grouped_df = df.groupby(df.columns[line_to_extract])['Run'].apply(lambda x: ','.join(x)).reset_index()
    grouped_df['combined'] = grouped_df.apply(lambda x: f"{x[0]}\t{x[1]}", axis=1)
    final_output = grouped_df['combined'].tolist()

    for line in final_output:
        print(line)

if __name__ == '__main__':
    file_path = sys.argv[1]
    line_to_extract = int(sys.argv[2])
    parse_SraRunTable(file_path, line_to_extract)
