sing="singularity exec --bind /work,/work2,/work3 /work3/SingularityImages/churros.2.0.0.sif"
build=hg38
Ddir=/work/Database/Database_fromDocker/Referencedata_$build
ncore=24

$sing churros --noqc --atac -p $ncore samplelist.txt samplepairlist.txt $build $Ddir
