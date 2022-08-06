sing="singularity exec --bind /work,/work2 /work/SingularityImages/churros.0.1.0.sif"
build=hg38

$sing churros_callpeak -p 10 samplepairlist.txt $build
