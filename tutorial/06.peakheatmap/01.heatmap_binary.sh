sing="apptainer exec --bind /work,/work2,/work3 /work3/SingularityImages/churros.2.0.0.sif"

gt=../01.ChIP-seq_human/Referencedata_hg38/genometable.txt
refregion=reference.bed

# Binary mode
$sing peakheatmap_binary -l samplelabel.tsv $refregion peakdir
