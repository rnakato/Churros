mkdir -p fastq
for id in #SRR13065962 SRR13065963 SRR13065966 SRR13065967 SRR13065972 SRR13065973 SRR13065974 SRR13065975
do
    singularity exec --bind /work,/work2 /work/SingularityImages/SRAtools.3.0.0.sif fastq-dump --gzip $id -O fastq &
done

# make index
sing="singularity exec --bind /work,/work2 /work/SingularityImages/churros.0.2.0.sif"
mkdir -p log
build=R64-1-1
ncore=24
$sing download_genomedata.sh $build Ensembl-$build/ 2>&1 | tee log/Ensembl-$build
$sing build-index.sh -p $ncore bowtie2 Ensembl-$build
