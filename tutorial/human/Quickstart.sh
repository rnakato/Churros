#sing="singularity exec --bind /work,/work2 /work/SingularityImages/churros.0.4.0.sif"
sing="singularity exec churros.0.4.0.sif"

build=hg38
Ddir=Referencedata_$build
ncore=24

$sing churros -p $ncore samplelist.txt samplepairlist.txt $build $Ddir

# specify output directory
$sing churros -p $ncore -D outputdir samplelist.txt samplepairlist.txt $build $Ddir

# implement comparative analysis
$sing churros -p $ncore --comparative samplelist.txt samplepairlist.txt $build $Ddir

# output p-value distribution
$sing churros -p $ncore --outputpvalue samplelist.txt samplepairlist.txt $build $Ddir
