sing="apptainer exec --bind /work,/work2,/work3 /work3/SingularityImages/churros.1.6.0.sif"
#sing="apptainer exec churros.sif"

build=mm10

$sing churros_compare samplelist.txt samplepairlist.txt $build
