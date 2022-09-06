sing="singularity exec --bind /work,/work2 /work/SingularityImages/churros.0.4.0.sif"
#sing="singularity exec churros.0.4.0.sif"

build=hg38
Ddir=Referencedata_$build

$sing churros_mapping -m -p 12 exec samplelist.txt $build $Ddir
# output QC stats
$sing churros_mapping -m header > churros.QCstats.tsv
$sing churros_mapping -m stats samplelist.txt $build $Ddir  >> churros.QCstats.tsv
