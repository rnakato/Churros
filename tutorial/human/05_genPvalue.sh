#sing="singularity exec --bind /work,/work2 /work/SingularityImages/churros.0.3.0.sif"
sing="singularity exec churros.0.3.0.sif"

build=hg38
Ddir=Ensembl-GRCh38
gt=$Ddir/genometable.txt

$sing churros_genPvalwig samplepairlist.txt drompa+.pval $build $gt

# consider mappability
$sing churros_genPvalwig -m samplepairlist.txt drompa+.pval $build $gt
