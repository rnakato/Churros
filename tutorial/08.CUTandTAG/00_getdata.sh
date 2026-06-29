sing="apptainer exec --bind /work,/work2,/work3 /work3/SingularityImages/churros.2.0.0.sif"

mkdir -p fastq
for id in #SRR12246717 SRR11074240 SRR11074254 SRR11074258 SRR11923224 SRR8754611
#SRX8754646 SRX7713678 SRX7713692 SRX7713696 SRX8468909 SRX5545346
do
    $sing pfastq-dump -t 4 -s $id -O fastq/ --gzip --split-files
done

#exit

mkdir -p log
build=hg38
ncore=24
Ddir=Referencedata_$build
$sing download_genomedata.sh -s $build $Ddir 2>&1 | tee log/$Ddir
$sing build-index.sh -p $ncore bowtie2 $Ddir
