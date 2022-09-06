sing="singularity exec --bind /work,/work2 /work/SingularityImages/churros.0.4.0.sif"
#sing="singularity exec churros.0.4.0.sif"

build=hg38
Ddir=Referencedata_$build
ncore=48

#$sing churros -D results0.4.0 -p $ncore samplelist.txt samplepairlist.txt $build $Ddir
$sing churros -p $ncore samplelist.txt samplepairlist.txt $build $Ddir

exit
# consider mappability
$sing churros -p $ncore --mpbl samplelist.txt samplepairlist.txt $build $Ddir

# specify output directory
$sing churros -p $ncore -D outputdir samplelist.txt samplepairlist.txt $build $Ddir

# output p-value distribution
$sing churros -p $ncore --mpbl --outputpvalue samplelist.txt samplepairlist.txt $build $Ddir
