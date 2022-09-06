sing="singularity exec --bind /work,/work2 /work/SingularityImages/churros.0.4.0.sif"
#sing="singularity exec churros.0.4.0.sif"

build=hg38

$sing churros_callpeak -p 8 samplepairlist.txt $build

# supply '-F' option tooverwrite existing MACS results
#$sing churros_callpeak -F -p 8 samplepairlist.txt $build
