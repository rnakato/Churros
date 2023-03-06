#sing="singularity exec --bind /work,/work2 /work/SingularityImages/churros.0.8.0.sif"
sing="singularity exec churros.0.8.0.sif"

mkdir -p fastq
for id in SRR299029 SRR299037 SRR299038 SRR299040 SRR299042
do
    fastq-dump --gzip $id -O fastq
done

mkdir -p log
build=mm10
ncore=24
Ddir=Referencedata_$build
$sing download_genomedata.sh $build $Ddir 2>&1 | tee log/$Ddir
$sing build-index.sh -p $ncore bowtie2 $Ddir
