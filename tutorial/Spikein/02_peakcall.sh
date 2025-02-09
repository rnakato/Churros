sing="singularity exec --bind /work,/work2,/work3 /work3/SingularityImages/churros.1.4.0.sif"
#sing="singularity exec churros.sif"

build=hg38

$sing churros_callpeak -t 8 samplepairlist.txt $build