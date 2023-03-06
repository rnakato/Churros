#sing="singularity exec --bind /work,/work2 /work/SingularityImages/churros.0.8.0.sif"
sing="singularity exec churros.0.8.0.sif"

build=hg38
Ddir=Referencedata_$build
gt=$Ddir/genometable.txt

$sing churros_genPvalwig samplepairlist.txt bedGraph_pval $build $gt
