mkdir -p fastq
for id in #SRR227447 SRR227448 SRR227552 SRR227553 SRR227563 SRR227564 SRR227575 SRR227576 SRR227598 SRR227599 SRR227639 SRR227640
do
    fastq-dump --gzip $id -O fastq
done

# make index
sing="singularity exec --bind /work,/work2 /work/SingularityImages/churros.0.1.0.sif"
mkdir -p log
build=GRCh38
ncore=24
$sing download_genomedata.sh $build Ensembl-$build/ 2>&1 | tee log/Ensembl-$build
$sing build-index.sh -p $ncore bowtie2 Ensembl-$build

# download mappability files from GooglrDrive
# https://drive.google.com/file/d/1VuxMv25AomaYvVnn7X7KfaW4LRDsdaVk/view?usp=sharing
# put the data in Ensembl-$build directory
