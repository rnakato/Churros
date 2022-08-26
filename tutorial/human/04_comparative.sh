sing="singularity exec --bind /work,/work2 /work/SingularityImages/churros.0.2.0.sif"
build=hg38

$sing churros_compare -m samplelist.txt $build
