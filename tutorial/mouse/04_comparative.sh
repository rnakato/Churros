#sing="singularity exec --bind /work,/work2 /work/SingularityImages/churros.0.4.0.sif"
sing="singularity exec churros.0.4.0.sif"

build=mm10

$sing churros_compare samplelist.txt samplepairlist.txt $build
