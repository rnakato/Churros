sing="singularity exec --bind /work,/work2,/work3 /work3/SingularityImages/churros.1.4.1.sif"

ncore=48
build=hg38
build_spikein=dm6
Ddir_ref=Referencedata_$build
Ddir_spikein=Referencedata_$build_spikein

$sing churros --noqc -p $ncore --spikein samplelist.txt samplepairlist.txt \
      $build $Ddir_ref --build_spikein $build_spikein --Ddir_spikein $Ddir_spikein
#$sing churros_visualize -G samplepairlist.txt drompa+ $build $Ddir_ref


#$sing churros_mapping_spikein exec samplelist.one.txt samplepairlist.one.txt hg38 mm39 $Ddir_ref $Ddir_spikein -p $ncore

#~/DockerFiles/Churros/Dockerfiles/Churros/churros_mapping_spikein exec samplelist.one.txt samplepairlist.one.txt hg38 mm39 /work/Database/Database_fromDocker/Referencedata_hg38/ /work/Database/Database_fromDocker/Referencedata_mm39/ -p 24 #-D Churros_result/hg38
