sing="singularity exec --bind /work,/work2,/work3 /work3/SingularityImages/churros.1.4.1.sif"
#sing="singularity exec churros.sif"

build=hg38
build_spikein=dm6
Ddir_ref=Referencedata_${build}
Ddir_spikein=Referencedata_${build_spikein}
ncore=48

# mapping, QC and generate wig files
$sing churros_mapping_spikein exec samplelist.txt samplepairlist.txt ${build} ${build_spikein} \
      ${Ddir_ref} ${Ddir_spikein} -p ${ncore}

# output QC stats
$sing churros_mapping header samplelist.txt $build $Ddir > churros.QCstats.tsv
$sing churros_mapping stats samplelist.txt $build $Ddir >> churros.QCstats.tsv
