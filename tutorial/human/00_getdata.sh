#sing="singularity exec --bind /work,/work2 /work/SingularityImages/churros.0.4.0.sif"
sing="singularity exec churros.0.4.0.sif"

mkdir -p fastq
for id in SRR227447 SRR227448 SRR227552 SRR227553 SRR227563 SRR227564 SRR227575 SRR227576 SRR227598 SRR227599 SRR227639 SRR227640
do
    $sing fastq-dump --gzip $id -O fastq
done

mkdir -p log
build=hg38
ncore=24
Ddir=Referencedata_$build
$sing download_genomedata.sh $build $Ddir 2>&1 | tee log/$Ddir
$sing build-index.sh -p $ncore bowtie2 $Ddir
