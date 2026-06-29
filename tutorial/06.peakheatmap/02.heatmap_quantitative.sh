sing="apptainer exec --bind /work,/work2,/work3 /work3/SingularityImages/churros.2.0.0.sif"

# Assume that the tutorial in 01.ChIP-seq_human has been run and the bigWig files are available in the following directory.
bwdir=../01.ChIP-seq_human/Churros_result/hg38/bigWig/TotalReadNormalized/
bws=`ls $bwdir/*.100.bw`

gt=../01.ChIP-seq_human/Referencedata_hg38/genometable.txt
refregion=reference.bed

# Quantitative mode
$sing peakheatmap_quantitative -b 1000 $gt $refregion "$bws"