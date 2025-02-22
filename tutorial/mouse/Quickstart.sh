sing="singularity exec --bind /work,/work2,/work3 /work3/SingularityImages/churros.1.4.1.sif"
#sing="singularity exec churros.sif"

build=mm10
Ddir=Referencedata_mm10/
ncore=24

$sing churros -p $ncore samplelist.txt samplepairlist.txt $build $Ddir
exit

# specify output directory
$sing churros -p $ncore -D outputdir samplelist.txt samplepairlist.txt $build $Ddir

# implement comparative analysis
$sing churros -p $ncore --comparative samplelist.txt samplepairlist.txt $build $Ddir

# output p-value distribution
$sing churros -p $ncore --outputpvalue samplelist.txt samplepairlist.txt $build $Ddir
