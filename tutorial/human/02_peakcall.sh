#sing="singularity exec --bind /work,/work2,/work3 /work3/SingularityImages/churros.1.1.1.sif"
sing="singularity exec churros.sif"

build=hg38

$sing churros_callpeak -p 8 samplepairlist.txt $build

# supply '-F' option tooverwrite existing MACS results
$sing churros_callpeak -F -p 8 samplepairlist.txt $build
