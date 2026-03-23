sing="apptainer exec --bind /work,/work2,/work3 /work3/SingularityImages/churros.1.6.0.sif"
#sing="apptainer exec churros.sif"

build=hg38
Ddir=Referencedata_$build
gt=$Ddir/genometable.txt

$sing churros_genPvalwig samplepairlist.txt bedGraph_Pval $build $gt
