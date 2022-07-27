sing="singularity exec --bind /work,/work2 /work/SingularityImages/churros.0.1.0.sif"
build=hg38
Ddir=/work/Database/Database_fromDocker/Ensembl-GRCh38

mkdir -p pdf
$sing churros_visualize samplepairlist.txt pdf/drompa+ $build $Ddir
$sing churros_visualize macs/samplepairlist.txt pdf/drompa+.macspeak $build $Ddir
$sing churros_visualize -b 5000 -l 8000 -P "--scale_tag 100" samplepairlist.txt pdf/drompa+.bin5M $build $Ddir
$sing churros_visualize -G macs/samplepairlist.txt pdf/drompa+ $build $Ddir
