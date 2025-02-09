sing="singularity exec --bind /work,/work2,/work3 /work3/SingularityImages/churros.1.4.1.sif"
#sing="singularity exec churros.sif"

mkdir -p fastq
for id in SRR1536557 SRR1536558 SRR1536559 SRR1536560 SRR1536561 SRR1584489 SRR1584490 SRR1584491 SRR1584492 SRR1584493
do
    $sing parallel-fastq-dump --sra-id $id --threads 4 --outdir fastq/ --gzip
done

mkdir -p log

for build in hg38 dm6
do
    ncore=24
    Ddir=Referencedata_$build
    $sing download_genomedata.sh $build $Ddir 2>&1 | tee log/$Ddir
    $sing build-index.sh -p $ncore bowtie2 $Ddir
done