sing="apptainer exec --bind /work,/work2,/work3 /work3/SingularityImages/churros.1.6.0.sif"
#sing="apptainer exec churros.sif"

build=hg38
Ddir=Referencedata_$build
index=$Ddir/bismark-indexes_genome/
ncore=24

$sing Bismark.sh -p $ncore -m rrbs $index fastq/SRR1609039.fastq.gz
$sing Bismark.sh -p $ncore -m rrbs $index fastq/SRR1609040.fastq.gz
