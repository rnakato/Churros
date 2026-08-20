sing="apptainer exec --bind /work,/work2,/work3 /work3/SingularityImages/churros.2.1.1.sif"

build=hg38
Ddir=Referencedata_$build

$sing churros_FRiR samplelist.txt Churros_result hg38 $Ddir
