sing="apptainer exec --bind /work,/work2,/work3 /work3/SingularityImages/churros.1.6.0.sif"
#sing="apptainer exec churros.sif"

build=hg38

$sing churros_callpeak -t 8 samplepairlist.txt $build