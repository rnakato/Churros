sing="singularity exec --bind /work,/work2 /work/SingularityImages/churros.0.1.0.sif"
build=hg38
Ddir=/work/Database/Database_fromDocker/Ensembl-GRCh38

mkdir -p pdf
$sing churros_visualize samplepairlist.txt pdf/drompa+ $build $Ddir
