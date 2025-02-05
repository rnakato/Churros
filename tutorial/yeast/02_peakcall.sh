sing="singularity exec --bind /work,/work2,/work3 /work3/SingularityImages/churros.1.4.0.sif"
#sing="singularity exec churros.sif"

build=sacCer3

$sing churros_callpeak -t 10 samplepairlist.txt $build

# overwrite existing MACS results
$sing churros_callpeak -F -t 10 samplepairlist.txt $build
