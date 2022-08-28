sing="singularity exec --bind /work,/work2 /work/SingularityImages/churros.0.3.0.sif"
build=sacCer3
Ddir=Ensembl-R64-1-1
ncore=48

$sing churros --preset scer -p $ncore --outputpvalue samplelist.txt samplepairlist.txt $build $Ddir
