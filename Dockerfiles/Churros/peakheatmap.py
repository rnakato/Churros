#! /usr/bin/env python
# -*- coding: utf-8 -*-
# Copyright(c) Ryuichiro Nakato <rnakato@iqb.u-tokyo.ac.jp>
# All rights reserved.

"""Process a genomic matrix, sort rows, cluster rows, and draw heatmaps.

The command-line interface and output file names are kept compatible with the
original classheat.py script:

    Output2_sorted_matrix.tsv
    Output3_sorted_heatmap.png
    Output4_kmeans_matrix.tsv
    Output5_kmeans_heatmap.png
"""

from __future__ import annotations

import argparse
import os
from pathlib import Path
from typing import Optional, Sequence, Tuple

# Set BLAS/OpenMP thread limits before importing NumPy/SciPy/scikit-learn.
os.environ.setdefault("OPENBLAS_NUM_THREADS", "1")
os.environ.setdefault("GOTO_NUM_THREADS", "1")
os.environ.setdefault("OMP_NUM_THREADS", "1")

import matplotlib

matplotlib.use("Agg")
import matplotlib.patches as mpatches
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import numpy as np
import pandas as pd
import seaborn as sns
from sklearn.decomposition import PCA
from sklearn.cluster import MiniBatchKMeans


VALID_MODES = {"quantitative", "binary"}
VALID_NORMALIZATIONS = {"zscore", "scale0to1"}
VALID_CLUSTER_METHODS = {
    "minikmeans",
    "kmeans",
    "spectral",
    "meanshift",
    "dbscan",
    "affinity",
}

SORTED_MATRIX = "Output2_sorted_matrix.tsv"
SORTED_HEATMAP = "Output3_sorted_heatmap.png"
KMEANS_MATRIX = "Output4_kmeans_matrix.tsv"
KMEANS_HEATMAP = "Output5_kmeans_heatmap.png"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Process and plot matrix")
    parser.add_argument("mode", type=str, choices=sorted(VALID_MODES), help="quantitative or binary")
    parser.add_argument("rawmt", type=str, help="path to rawmt data")
    parser.add_argument("--sortname", type=str, default="", help="name of sort")
    parser.add_argument("--kcluster", type=int, default=3, help="number of clusters (default: 3)")
    parser.add_argument("--outdir", type=str, default="output", help="output directory (default: output)")
    parser.add_argument(
        "--samplelabeltsv",
        type=str,
        default="",
        help=(
            "Labels for the samples. Two tab-separated columns: "
            "1st column is file/sample name, 2nd column is label"
        ),
    )
    parser.add_argument(
        "--normalize",
        type=str,
        default="zscore",
        choices=sorted(VALID_NORMALIZATIONS),
        help="normalization method after log [zscore, scale0to1]",
    )
    parser.add_argument(
        "--clustermethod",
        type=str,
        default="minikmeans",
        choices=sorted(VALID_CLUSTER_METHODS),
        help="clustering algorithm [minikmeans, kmeans, spectral, meanshift, dbscan, affinity]",
    )
    return parser.parse_args()


def load_matrix(rawmt: str | Path) -> pd.DataFrame:
    """Load the raw tab-separated matrix."""
    df = pd.read_csv(rawmt, sep="\t")
    if df.shape[1] < 4:
        raise ValueError("Input matrix must contain at least 3 coordinate columns and 1 data column.")
    return df


def make_position_index(df: pd.DataFrame) -> list[str]:
    """Create chr-start-end style row labels from the first three columns."""
    posdf = df.iloc[:, 0:3].astype(str).copy()
    return posdf.apply(lambda row: "-".join(row), axis=1).tolist()


def extract_signal_matrix(df: pd.DataFrame) -> pd.DataFrame:
    """Return the signal matrix with position strings as the index."""
    matrix = df.iloc[:, 3:].copy()
    matrix.index = make_position_index(df)
    return matrix


def process_matrix(matrix: pd.DataFrame, mode: str, normalize: str) -> pd.DataFrame:
    """Transform the signal matrix according to the selected mode."""
    if mode == "binary":
        return matrix.copy()

    log_matrix = np.log1p(matrix)
    if normalize == "zscore":
        return (log_matrix - log_matrix.mean()) / log_matrix.std()
    if normalize == "scale0to1":
        return log_matrix / log_matrix.max().max()

    raise ValueError(f"Unsupported normalization method: {normalize}")


def sort_matrix(matrix: pd.DataFrame, sortname: str) -> pd.DataFrame:
    """Sort rows by a requested column or by the first data column."""
    if sortname and sortname != "defaultUseFirstColumn":
        if sortname not in matrix.columns:
            raise ValueError(f"--sortname '{sortname}' was not found in matrix columns.")
        sort_column = sortname
    else:
        sort_column = matrix.columns[0]
    return matrix.sort_values(by=sort_column)


def split_position_index(index: Sequence[str]) -> pd.DataFrame:
    """Convert chr-start-end row labels back to coordinate columns."""
    pos = pd.DataFrame([x.split("-", 2) for x in index], columns=["chromosome", "start", "end"])
    pos.index = index
    return pos


def write_matrix_with_positions(matrix: pd.DataFrame, path: str | Path) -> None:
    """Write a matrix preceded by chromosome, start, and end columns."""
    pos = split_position_index(matrix.index)
    pd.concat([pos, matrix], axis=1).to_csv(path, sep="\t", index=False)


def load_sample_labels(samplelabeltsv: str | Path, columns: Sequence[str]) -> Tuple[pd.Series, dict, list]:
    """Load sample labels and return seaborn-compatible column colors."""
    matrix_label = pd.DataFrame({"name": list(columns)})
    sample_label = pd.read_csv(samplelabeltsv, sep="\t", header=None, usecols=[0, 1])
    sample_label.columns = ["name", "label"]

    sample_label_mt = pd.merge(matrix_label, sample_label, on="name", how="left")
    sample_label_mt.index = sample_label_mt["name"]
    labels = sample_label_mt["label"].fillna("NA")

    palette = sns.color_palette("hls", len(labels.unique()))
    label_to_color = dict(zip(labels.unique(), palette))
    col_colors = labels.map(label_to_color)
    patches = [mpatches.Patch(color=color, label=label) for label, color in label_to_color.items()]
    return col_colors, label_to_color, patches


def heatmap_parameters(mode: str) -> dict:
    """Return heatmap options shared by sorted and clustered plots."""
    if mode == "quantitative":
        return {"cmap": "RdBu_r", "center": 0, "vmax": 4, "vmin": -4}
    if mode == "binary":
        return {"cmap": "Purples", "vmax": 2}
    raise ValueError(f"Unsupported mode: {mode}")


def add_label_legend(patches: Optional[list]) -> None:
    if patches:
        plt.legend(
            handles=patches,
            bbox_to_anchor=(0.15, 0.7),
            loc="best",
            bbox_transform=plt.gcf().transFigure,
        )


def draw_heatmap(
    matrix: pd.DataFrame,
    mode: str,
    output_path: str | Path,
    col_colors: Optional[pd.Series] = None,
    row_colors: Optional[pd.Series] = None,
    patches: Optional[list] = None,
) -> None:
    """Draw and save a seaborn clustermap with row clustering disabled."""
    kwargs = heatmap_parameters(mode)
    grid = sns.clustermap(
        matrix,
        row_cluster=False,
        yticklabels=False,
        figsize=(10, 10),
        xticklabels=True,
        col_colors=col_colors,
        row_colors=row_colors,
        **kwargs,
    )
    add_label_legend(patches)
    grid.savefig(output_path, dpi=300)
    plt.close(grid.fig)


def build_cluster_model(method: str, ncluster: int, seed: int):
    """Create the clustering model selected by --clustermethod."""
    if method == "minikmeans":
        return MiniBatchKMeans(random_state=seed, n_clusters=ncluster, max_iter=10000, batch_size=100)
    if method == "kmeans":
        from sklearn.cluster import KMeans

        return KMeans(random_state=seed, n_clusters=ncluster)
    if method == "spectral":
        from sklearn.cluster import SpectralClustering

        return SpectralClustering(random_state=seed, n_clusters=ncluster)
    if method == "meanshift":
        from sklearn.cluster import MeanShift

        return MeanShift()
    if method == "dbscan":
        from sklearn.cluster import DBSCAN

        return DBSCAN(eps=3, min_samples=2)
    if method == "affinity":
        from sklearn.cluster import AffinityPropagation

        return AffinityPropagation(random_state=seed)
    raise ValueError(f"Unsupported clustering method: {method}")


def dim_reduction_cluster(
    data: pd.DataFrame,
    ncluster: int,
    method: str,
    seed: int = 0,
    num_pca: int = 10,
) -> np.ndarray:
    """Run PCA followed by the selected clustering method."""
    if data.shape[0] < 2:
        raise ValueError("At least two rows are required for PCA/clustering.")

    n_components = min(num_pca, data.shape[0], data.shape[1])
    pca = PCA(n_components=n_components)
    reduced = pca.fit_transform(data)

    model = build_cluster_model(method, ncluster, seed)
    return model.fit_predict(reduced)


def make_row_colors(labels: pd.Series) -> pd.Series:
    """Assign row colors to cluster labels."""
    color_list = list(mcolors.TABLEAU_COLORS.keys())
    unique_labels = list(labels.unique())
    color_map = {label: color_list[i % len(color_list)] for i, label in enumerate(unique_labels)}
    return labels.map(color_map)


def run(args: argparse.Namespace) -> None:
    outdir = Path(args.outdir)
    outdir.mkdir(parents=True, exist_ok=True)

    raw_df = load_matrix(args.rawmt)
    signal_matrix = extract_signal_matrix(raw_df)
    processed_matrix = process_matrix(signal_matrix, args.mode, args.normalize)

    sorted_matrix = sort_matrix(processed_matrix, args.sortname)
    write_matrix_with_positions(sorted_matrix, outdir / SORTED_MATRIX)

    sorted_col_colors = None
    sorted_patches = None
    if args.samplelabeltsv:
        sorted_col_colors, _, sorted_patches = load_sample_labels(args.samplelabeltsv, sorted_matrix.columns)

    draw_heatmap(
        sorted_matrix,
        mode=args.mode,
        output_path=outdir / SORTED_HEATMAP,
        col_colors=sorted_col_colors,
        patches=sorted_patches,
    )

    clustered_matrix = processed_matrix.copy(deep=True)
    clustered_matrix["kmeans"] = dim_reduction_cluster(
        clustered_matrix,
        ncluster=args.kcluster,
        method=args.clustermethod,
    )
    clustered_matrix = clustered_matrix.sort_values(by=["kmeans"])
    write_matrix_with_positions(clustered_matrix, outdir / KMEANS_MATRIX)

    cluster_labels = clustered_matrix["kmeans"]
    row_colors = make_row_colors(cluster_labels)
    clustered_matrix_no_label = clustered_matrix.iloc[:, 0 : clustered_matrix.shape[1] - 1]

    clustered_col_colors = None
    clustered_patches = None
    if args.samplelabeltsv:
        clustered_col_colors, _, clustered_patches = load_sample_labels(
            args.samplelabeltsv,
            clustered_matrix_no_label.columns,
        )

    draw_heatmap(
        clustered_matrix_no_label,
        mode=args.mode,
        output_path=outdir / KMEANS_HEATMAP,
        col_colors=clustered_col_colors,
        row_colors=row_colors,
        patches=clustered_patches,
    )


def main() -> None:
    args = parse_args()
    run(args)


if __name__ == "__main__":
    main()
