sing="apptainer exec --bind /work,/work2,/work3 /work3/SingularityImages/churros.2.0.0.sif"

build=hg38

$sing churros_callpeak -t 8 samplepairlist.txt $build

# supply '-F' option tooverwrite existing MACS results
$sing churros_callpeak -F -t 8 samplepairlist.txt $build
