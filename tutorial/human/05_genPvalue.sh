#sing="singularity exec --bind /work,/work2,/work3 /work3/SingularityImages/churros.1.1.1.sif"
sing="singularity exec churros.sif"

build=hg38
Ddir=Referencedata_$build
gt=$Ddir/genometable.txt

$sing churros_genPvalwig samplepairlist.txt bedGraph_Pval $build $gt
