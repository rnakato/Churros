#sing="singularity exec --bind /work,/work2 /work/SingularityImages/churros.0.3.0.sif"
sing="singularity exec churros.0.3.0.sif"

build=sacCer3
Ddir=Ensembl-R64-1-1

# mapping, QC and generate wig files
$sing churros_mapping exec samplelist.txt $build $Ddir

# output QC stats
$sing churros_mapping header > churros.QCstats.tsv
$sing churros_mapping stats samplelist.txt $build $Ddir >> churros.QCstats.tsv
