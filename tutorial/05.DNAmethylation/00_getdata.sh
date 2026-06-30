sing="apptainer exec --bind /work,/work2,/work3 /work3/SingularityImages/churros.2.0.0.sif"

mkdir -p fastq
for id in SRR1609039 SRR1609040
do
    $sing pfastq-dump -s $id -t 4 --outdir fastq/ --gzip
done

mkdir -p log
build=hg38
ncore=24
Ddir=Referencedata_$build
$sing download_genomedata.sh -s $build $Ddir 2>&1 | tee log/$Ddir
$sing build-index.sh -p $ncore bismark $Ddir
