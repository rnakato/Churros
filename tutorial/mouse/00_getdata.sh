mkdir -p fastq
for id in #SRR299029 SRR299037 SRR299038 SRR299040 SRR299042
do
    fastq-dump --gzip $id -O fastq
done

# make index
sing="singularity exec --bind /work,/work2 /work/SingularityImages/churros.0.2.0.sif"
mkdir -p log
build=GRCm38
ncore=24
$sing download_genomedata.sh $build Ensembl-$build/ 2>&1 | tee log/Ensembl-$build
$sing build-index.sh -p $ncore bowtie2 Ensembl-$build

# download mappability files from GoogleDrive
# https://drive.google.com/file/d/1VuxMv25AomaYvVnn7X7KfaW4LRDsdaVk/view?usp=sharing
# put the data in Ensembl-$build directory
