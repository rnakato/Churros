#! /usr/bin/env python
# -*- coding: utf-8 -*-

import os
import argparse
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np
import scipy.stats as stats
from sklearn.decomposition import PCA
from sklearn.cluster import MiniBatchKMeans
import matplotlib.cm
import matplotlib.colors as mcolors

os.environ['OPENBLAS_NUM_THREADS'] = '1'
os.environ['GOTO_NUM_THREADS'] = '1'
os.environ['OMP_NUM_THREADS'] = '1'

parser = argparse.ArgumentParser(description='Process and plot matrix')
parser.add_argument('mode', type=str, help='continuous or binary')
parser.add_argument('rawmt', type=str, help='path to rawmt data')
parser.add_argument('--sortname', type=str, default="", help='name of sort')
parser.add_argument('--kcluster', type=int, default=3, help='number of clusters (default: 3)')
parser.add_argument('--outdir', type=str, default='output', help='output directory (default: output)')
parser.add_argument('--samplelabeltsv', type=str, default='', help='Labels for the samples (e.g., celltypes, datasets, antibody types..). Two columns separated by tab, 1st column is file name, 2nd column is the label')
parser.add_argument('--normalize', type=str, default="zscore", help='normalization method after log [zscore, scale0to1]')
parser.add_argument('--clustermethod', type=str, default="minikmeans", help='clustering algorithm [minikmeans, kmeans, spectral, meanshift, dbscan, affinity ]')

args = parser.parse_args()
rawmt = args.rawmt
mode = args.mode
sortname = args.sortname
kcluster = args.kcluster
outdir = args.outdir
samplelabeltsv = args.samplelabeltsv
normalize = args.normalize
clustermethod = args.clustermethod

#print(args.rawmt,args.sortname,args.kcluster,args.outdir)

df = pd.read_csv(rawmt,sep="\t")
posdf = df.iloc[:,0:3]
posdf.iloc[:,1] = posdf.iloc[:,1].astype(str)
posdf.iloc[:,2] = posdf.iloc[:,2].astype(str)
posdf['joined'] = posdf.apply(lambda row: '-'.join(row), axis=1)
poslist = posdf['joined'].tolist()

ci = df.iloc[:,3:]
ci.index = poslist

if mode == 'continuous': 
    logci = np.log1p(ci)

    if normalize == "zscore":
        zscore_logci = (logci - logci.mean())/logci.std()
    elif normalize == "scale0to1":
        zscore_logci = logci/(logci.max().max())
    else:
        print("please choose the correct type")
        exit(1)

    processedmt = zscore_logci
elif mode == 'binary':
    processedmt = ci
else:
    print("Please choose continuous or binary")
    exit(1)

if sortname != "defaultUseFirstColumn":
    sortDF = processedmt.sort_values(by=sortname)
else:
    sortDF = processedmt.sort_values(by=processedmt.columns[0])

sortDFpos = pd.DataFrame([x.split('-') for x in sortDF.index], columns=['chromosome', 'start', 'end'])
sortDFpos.index = sortDF.index
pd.concat([sortDFpos,sortDF],axis=1).to_csv(outdir+"/Output2_sorted_matrix.tsv",sep="\t",index=False)

if samplelabeltsv:
    matrixlabel = pd.DataFrame({'name': sortDF.columns})
    samplelabel=pd.read_csv(samplelabeltsv,sep="\t",header=None)
    samplelabel.columns=['name','label']

    samplelabelmt = pd.merge(matrixlabel,samplelabel,on='name', how='left')
    samplelabelmt.index = samplelabelmt['name']
    samplelabellist = samplelabelmt['label']
    allcolorforcol = sns.color_palette("hls", len(samplelabellist.unique()))
    columndic = dict(zip(samplelabellist.unique(), allcolorforcol))
    col_colors = samplelabellist.map(columndic)
    import matplotlib.patches as mpatches
    patches = [mpatches.Patch(color=columndic[label], label=label) for label in columndic]

if mode == 'continuous':
    if not samplelabeltsv:
        sortheat = sns.clustermap(sortDF, cmap="RdBu_r", center=0, vmax=4, vmin=-4,
               row_cluster=False, yticklabels=False, figsize=(10,10), xticklabels=True)
    else:
        sortheat = sns.clustermap(sortDF, cmap="RdBu_r", center=0, vmax=4, vmin=-4, col_colors=col_colors,
               row_cluster=False, yticklabels=False, figsize=(10,10), xticklabels=True)
        plt.legend(handles=patches, bbox_to_anchor=(0.15, 0.7), loc='best', bbox_transform=plt.gcf().transFigure)

elif mode == 'binary':
    if not samplelabeltsv:
        sortheat = sns.clustermap(sortDF, cmap="Purples",vmax=2,
               row_cluster=False, yticklabels=False, figsize=(10,10), xticklabels=True)
    else:
        sortheat = sns.clustermap(sortDF, cmap="Purples", vmax=2, col_colors=col_colors,
               row_cluster=False, yticklabels=False, figsize=(10,10), xticklabels=True)
        plt.legend(handles=patches, bbox_to_anchor=(0.15, 0.7), loc='best', bbox_transform=plt.gcf().transFigure)

else:
    print("Please choose continuous or binary")
    exit(1)

sortheat.savefig(outdir+"/Output3_sorted_heatmap.png", dpi=300)

def DimReduction(data, ncluster,seed=0,num_pca=10):
    pca = PCA(n_components=num_pca)
    pca.fit(data)
    matrix = pca.transform(data)
    if clustermethod=='minikmeans':
        model = MiniBatchKMeans(random_state=seed, n_clusters=ncluster, max_iter=10000, batch_size=100)
    elif clustermethod=='kmeans':
        from sklearn.cluster import KMeans
        model = KMeans(random_state=seed, n_clusters=ncluster)
    elif clustermethod=='spectral':
        from sklearn.cluster import SpectralClustering
        model = SpectralClustering(random_state=seed, n_clusters=ncluster)
    elif clustermethod=='meanshift':
        from sklearn.cluster import MeanShift
        model = MeanShift()
    elif clustermethod=='dbscan':
        from sklearn.cluster import DBSCAN
        model = DBSCAN(eps=3, min_samples=2)
    elif clustermethod=='affinity':
        from sklearn.cluster import AffinityPropagation
        AffinityPropagation(random_state=seed)
    else:
        raise("please use the correst cluster method")
        exit(1)
    outlabels = model.fit_predict(matrix)
    return outlabels

# add k-mean informatio to the last column
kmeanDF = processedmt.copy(deep=True)
ncluster = kcluster

kmeanDF["kmeans"] = DimReduction(kmeanDF, ncluster)
kmeanDF = kmeanDF.sort_values(by=['kmeans'])

kmeanDFpos = pd.DataFrame([x.split('-') for x in kmeanDF.index], columns=['chromosome', 'start', 'end'])
kmeanDFpos.index = kmeanDF.index
pd.concat([kmeanDFpos,kmeanDF],axis=1).to_csv(outdir+"/Output4_kmeans_matrix.tsv",sep="\t",index=False)

# prepare for plot
colist = list(mcolors.TABLEAU_COLORS.keys())
lut = dict(zip(kmeanDF["kmeans"].unique(), colist))
row_colors = kmeanDF["kmeans"].map(lut)

kmeanDF_nolabel = kmeanDF.iloc[:,0:kmeanDF.shape[1]-1]

if samplelabeltsv:
    matrixlabel = pd.DataFrame({'name': kmeanDF_nolabel.columns})
    samplelabel=pd.read_csv(samplelabeltsv,sep="\t",header=None)
    samplelabel.columns=['name','label']
    samplelabelmt = pd.merge(matrixlabel,samplelabel,on='name', how='left')
    samplelabelmt.index = samplelabelmt['name']
    samplelabellist = samplelabelmt['label']
    allcolorforcol = sns.color_palette("hls", len(samplelabellist.unique()))
    columndic = dict(zip(samplelabellist.unique(), allcolorforcol))
    col_colors = samplelabellist.map(columndic)
    import matplotlib.patches as mpatches
    patches = [mpatches.Patch(color=columndic[label], label=label) for label in columndic]

if mode == 'continuous':
    if not samplelabeltsv:
        sns_plot = sns.clustermap(kmeanDF_nolabel, row_colors=row_colors, row_cluster=False,
                         cmap="RdBu_r", yticklabels=False, center=0, vmax=4, vmin=-4,
                         figsize=(10,10), xticklabels=True)
    else:
        sns_plot = sns.clustermap(kmeanDF_nolabel, row_colors=row_colors, row_cluster=False,
                         cmap="RdBu_r", yticklabels=False, center=0, vmax=4, vmin=-4,
                         figsize=(10,10), xticklabels=True, col_colors=col_colors)
        plt.legend(handles=patches, bbox_to_anchor=(0.15, 0.7), loc='best', bbox_transform=plt.gcf().transFigure)

elif mode == 'binary':
    if not samplelabeltsv:
        sns_plot = sns.clustermap(kmeanDF_nolabel, row_colors=row_colors, row_cluster=False,
                         cmap="Purples", yticklabels=False, figsize=(10,10), xticklabels=True, vmax=2)
    else:
        sns_plot = sns.clustermap(kmeanDF_nolabel, row_colors=row_colors, row_cluster=False,
                         cmap="Purples", yticklabels=False, figsize=(10,10), xticklabels=True, vmax=2, col_colors=col_colors)
        plt.legend(handles=patches, bbox_to_anchor=(0.15, 0.7), loc='best', bbox_transform=plt.gcf().transFigure)

sns_plot.savefig(outdir+"/Output5_kmeans_heatmap.png", dpi=300)


