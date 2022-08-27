sing="singularity exec --bind /work,/work2 /work/SingularityImages/churros.0.2.0.sif"
#sing="singularity exec churros.0.2.0.sif"

build=sacCer3
Ddir=Ensembl-R64-1-1/

$sing churros_visualize samplepairlist.txt drompa+          $build $Ddir --preset scer --enrich
$sing churros_visualize samplepairlist.txt drompa+.logscale $build $Ddir --preset scer --enrich --logratio
