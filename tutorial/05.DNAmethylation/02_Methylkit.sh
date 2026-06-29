sing="apptainer exec --bind /work,/work2,/work3 /work3/SingularityImages/churros.2.0.0.sif"
#sing="apptainer exec churros.sif"

$sing R --vanilla < Methylkit.R
