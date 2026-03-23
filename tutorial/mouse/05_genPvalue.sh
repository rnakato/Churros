sing="apptainer exec --bind /work,/work2,/work3 /work3/SingularityImages/churros.1.6.0.sif"
#sing="apptainer exec churros.sif"

build=mm10
Ddir=Referencedata_mm10/
gt=$Ddir/genometable.txt

$sing churros_genPvalwig samplepairlist.txt bedGraph_Pval $build $gt
