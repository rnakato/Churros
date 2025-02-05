sing="singularity exec --bind /work,/work2,/work3 /work3/SingularityImages/churros.1.4.0.sif"
#sing="singularity exec churros.sif"

build=sacCer3
Ddir=Referencedata_$build

$sing churros_visualize samplepairlist.txt drompa+          $build $Ddir --preset scer --enrich
$sing churros_visualize samplepairlist.txt drompa+.logscale $build $Ddir --preset scer --enrich --logratio
