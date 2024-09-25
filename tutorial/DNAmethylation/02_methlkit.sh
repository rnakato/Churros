#sing="singularity exec --bind /work,/work2,/work3 /work3/SingularityImages/churros.1.2.1.sif"
sing="singularity exec churros.sif"

$sing R --vanilla < Methylkit.R