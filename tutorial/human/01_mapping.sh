#sing="singularity exec --bind /work,/work2,/work3 /work3/SingularityImages/churros.1.1.1.sif"
sing="singularity exec churros.sif"

build=hg38
Ddir=Referencedata_$build

# mapping, QC and generate wig files
$sing churros_mapping exec samplelist.txt $build $Ddir

# output QC stats
$sing churros_mapping header > churros.QCstats.tsv
$sing churros_mapping stats samplelist.txt $build $Ddir >> churros.QCstats.tsv
