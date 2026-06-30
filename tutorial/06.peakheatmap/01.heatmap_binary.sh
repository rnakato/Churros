sing="apptainer exec --bind /work,/work2,/work3 /work3/SingularityImages/churros.2.0.0.sif"

# Binary mode
$sing peakheatmap_binary -l samplelabel.tsv reference.bed peakdir
