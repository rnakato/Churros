#sing="singularity exec --bind /work,/work2 /work/SingularityImages/churros.0.3.0.sif"
sing="singularity exec churros.0.3.0.sif"

build=mm10

$sing churros_callpeak -p 10 samplepairlist.txt $build

# overwrite existing MACS results
$sing churros_callpeak -F -p 10 samplepairlist.txt $build
