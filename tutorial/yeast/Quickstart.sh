sing="singularity exec --bind /work,/work2,/work3 /work3/SingularityImages/churros.1.4.1.sif"
#sing="singularity exec churros.sif"

build=sacCer3
Ddir=Referencedata_$build
ncore=24

$sing churros --noqc --preset scer -p $ncore --outputpvalue --comparative samplelist.txt samplepairlist.txt $build $Ddir
