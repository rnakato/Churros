mkdir -p fastq

#sing="singularity exec --bind /work,/work2 /work/SingularityImages/churros.0.8.0.sif"
sing="singularity exec churros.0.8.0.sif"

for id in #SRR13065962 SRR13065963 SRR13065966 SRR13065967 SRR13065972 SRR13065973 SRR13065974 SRR13065975
do
    $sing fastq-dump --gzip $id -O fastq
done

mkdir -p log
build=sacCer3
Ddir=Referencedata_$build
ncore=24

$sing download_genomedata.sh $build $Ddir 2>&1 | tee log/$Ddir
$sing build-index.sh -p $ncore bowtie2 $Ddir
