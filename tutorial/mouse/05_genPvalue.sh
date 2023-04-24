#sing="singularity exec --bind /work,/work2 /work/SingularityImages/churros.0.9.0.sif"
sing="singularity exec churros.sif"

build=mm10
Ddir=Referencedata_mm10/
gt=$Ddir/genometable.txt

$sing churros_genPvalwig samplepairlist.txt bedGraph_Pval $build $gt
