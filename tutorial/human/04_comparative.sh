#sing="singularity exec --bind /work,/work2 /work/SingularityImages/churros.0.9.0.sif"
sing="singularity exec churros.sif"

build=hg38

$sing churros_compare samplelist.txt samplepairlist.txt $build
