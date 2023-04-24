sing="singularity exec --bind /work,/work2 /work/SingularityImages/churros.0.9.0.sif"
#sing="singularity exec churros.sif"

build=sacCer3
Ddir=Referencedata_$build
ncore=24

$sing churros --preset scer -p $ncore --outputpvalue --comparative samplelist.txt samplepairlist.txt $build $Ddir
