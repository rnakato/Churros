sing="singularity exec --bind /work,/work2,/work3 /work3/SingularityImages/churros.1.1.1.sif"
#sing="singularity exec churros.sif"

build=hg38

$sing churros_compare samplelist.txt samplepairlist.txt $build
