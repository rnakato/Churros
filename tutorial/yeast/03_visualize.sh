sing="singularity exec --bind /work,/work2 /work/SingularityImages/churros.0.2.0.sif"
build=sacCer3
Ddir=Ensembl-R64-1-1/

$sing churros_visualize samplepairlist.txt drompa+ sacCer3 Ensembl-R64-1-1/ --preset scer --enrich
$sing churros_visualize samplepairlist.txt drompa+.logscale sacCer3 Ensembl-R64-1-1/ --preset scer --enrich --logratio
