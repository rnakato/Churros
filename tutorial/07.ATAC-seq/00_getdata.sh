sing="apptainer exec --bind /work,/work2,/work3 /work3/SingularityImages/churros.2.0.0.sif"

mkdir -p fastq
for id in SRR2453157 SRR2453159 SRR2453158
do
    $sing pfastq-dump -t 4 -s $id -O fastq/ --gzip --split-files
done

mkdir -p log
build=hg38
ncore=24
Ddir=Referencedata_$build
$sing download_genomedata.sh -s $build $Ddir 2>&1 | tee log/$Ddir
$sing build-index.sh -p $ncore bowtie2 $Ddir
