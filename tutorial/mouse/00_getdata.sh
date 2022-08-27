mkdir -p fastq
for id in SRR299029 SRR299037 SRR299038 SRR299040 SRR299042
do
    fastq-dump --gzip $id -O fastq
done

#sing="singularity exec --bind /work,/work2 /work/SingularityImages/churros.0.2.0.sif"
sing="singularity exec churros.0.2.0.sif"

mkdir -p log
build=GRCm38
ncore=24
$sing download_genomedata.sh $build Ensembl-$build/ 2>&1 | tee log/Ensembl-$build
$sing build-index.sh -p $ncore bowtie2 Ensembl-$build
