sing="apptainer exec --bind /work,/work2,/work3 /work3/SingularityImages/churros.2.0.0.sif"

build=hg38
Ddir=Referencedata_$build
ncore=24

# Use the following parameters for Bowtie2 mapping recommended by the SEACR authors
btparam="--end-to-end --very-sensitive --no-mixed --no-discordant --phred33 -I 10 -X 700"
$sing churros -p $ncore --keepdup --fastqtrimming --mapparam "$btparam" samplelist.txt samplepairlist.txt $build $Ddir

#$sing churros_mapping -P "$btparam" exec sampletemp.txt $build $Ddir

# output QC stats
#$sing churros_mapping header sampletemp.txt $build $Ddir > churros.QCstats.tsv
#$sing churros_mapping stats sampletemp.txt $build $Ddir >> churros.QCstats.tsv
