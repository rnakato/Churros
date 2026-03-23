sing="apptainer exec --bind /work,/work2,/work3 /work3/SingularityImages/churros.1.6.0.sif"
#sing="apptainer exec churros.sif"

build=mm10
Ddir=Referencedata_$build

# mapping, QC and generate wig files
$sing churros_mapping -k 36 exec samplelist.txt $build $Ddir

# output QC stats
$sing churros_mapping header samplelist.txt $build $Ddir > churros.QCstats.tsv
$sing churros_mapping stats samplelist.txt $build $Ddir >> churros.QCstats.tsv
