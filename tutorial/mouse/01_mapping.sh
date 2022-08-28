#sing="singularity exec --bind /work,/work2 /work/SingularityImages/churros.0.3.0.sif"
sing="singularity exec churros.0.3.0.sif"

build=mm10
Ddir=Ensembl-GRCm38

# mapping, QC and generate wig files
$sing churros_mapping -m -k 36 exec samplelist.txt $build $Ddir

# output QC stats
$sing churros_mapping -m header > churros.QCstats.tsv
$sing churros_mapping -m stats samplelist.txt $build $Ddir >> churros.QCstats.tsv
