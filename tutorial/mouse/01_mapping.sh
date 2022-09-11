#sing="singularity exec --bind /work,/work2 /work/SingularityImages/churros.0.4.0.sif"
sing="singularity exec churros.0.4.0.sif"

build=mm10
Ddir=Referencedata_$build

# mapping, QC and generate wig files
$sing churros_mapping -k 36 exec samplelist.txt $build $Ddir

# output QC stats
$sing churros_mapping header > churros.QCstats.tsv
$sing churros_mapping stats samplelist.txt $build $Ddir >> churros.QCstats.tsv
