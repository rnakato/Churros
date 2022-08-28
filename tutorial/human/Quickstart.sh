sing="singularity exec --bind /work,/work2 /work/SingularityImages/churros.0.3.0.sif"
#sing="singularity exec churros.0.3.0.sif"

build=hg38
Ddir=Ensembl-GRCh38/
ncore=12

$sing churros -p $ncore samplelist.txt samplepairlist.txt $build $Ddir

# consider mappability
$sing churros -p $ncore --mpbl samplelist.txt samplepairlist.txt $build $Ddir

# specify output directory
$sing churros -p $ncore -D outputdir samplelist.txt samplepairlist.txt $build $Ddir

# output p-value distribution
$sing churros -p $ncore --mpbl --outputpvalue samplelist.txt samplepairlist.txt $build $Ddir
