sing="singularity exec --bind /work,/work2 /work/SingularityImages/churros.0.2.0.sif"
build=hg38
gt=

$sing churros_genPvalwig samplelist.txt $build $gt

# consider mappability
$sing churros_genPvalwig -m samplelist.txt $build $gt
