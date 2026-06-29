sing="apptainer exec --bind /work,/work2,/work3 /work3/SingularityImages/churros.2.0.0.sif"

build=hg38
Ddir=Referencedata_$build
gt=$Ddir/genometable.txt

Churrosdir=Churros_result/$build
ncore=8

$sing churros_SEACR -p $ncore samplelist.txt samplepairlist.txt $Churrosdir $gt
