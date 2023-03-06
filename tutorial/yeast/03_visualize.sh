#sing="singularity exec --bind /work,/work2 /work/SingularityImages/churros.0.8.0.sif"
sing="singularity exec churros.0.8.0.sif"

build=sacCer3
Ddir=Referencedata_$build

$sing churros_visualize samplepairlist.txt drompa+          $build $Ddir --preset scer --enrich
$sing churros_visualize samplepairlist.txt drompa+.logscale $build $Ddir --preset scer --enrich --logratio
