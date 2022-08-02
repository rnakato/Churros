FASTQ=(
    "fastq/SRR227447.fastq.gz,fastq/SRR227448.fastq.gz"
    "fastq/SRR227552.fastq.gz,fastq/SRR227553.fastq.gz"
    "fastq/SRR227563.fastq.gz,fastq/SRR227564.fastq.gz"
    "fastq/SRR227575.fastq.gz,fastq/SRR227576.fastq.gz"
    "fastq/SRR227598.fastq.gz,fastq/SRR227599.fastq.gz"
    "fastq/SRR227639.fastq.gz,fastq/SRR227640.fastq.gz"
)

NAME=(
    "HepG2_H3K36me3"
    "HepG2_Control"
    "HepG2_H3K4me3"
    "HepG2_H3K27ac"
    "HepG2_H3K27me3"
    "HepG2_H2A.Z"
)

sing="singularity exec --bind /work,/work2 /work/SingularityImages/churros.0.1.0.sif"
build=hg38
Ddir=Ensembl-GRCh38

### Download mappability data from GoogleDrive
# https://drive.google.com/drive/folders/1MbBwGjRrlFkUh9ZWd6ev3o9hV_kg9K4-?usp=sharing
# Here we can use "Ensembl-GRCh38_mappability_Mosaics_36mer.tar.bz2"
#tar xvfj -C $Ddir Ensembl-GRCh38_mappability_Mosaics_36mer.tar.bz2

for i in 0 #((i=0; i<${#FASTQ[@]}; i++))
do
    echo ${NAME[$i]}
    $sing churros_mapping -m exec "${FASTQ[$i]}" ${NAME[$i]} $build $Ddir
done

exit

$sing churros_mapping head "${FASTQ[$i]}" label $build $Ddir > churros.stats.tsv
for ((i=0; i<${#FASTQ[@]}; i++))
do
    $sing churros_mapping stats "${FASTQ[$i]}" ${NAME[$i]} $build $Ddir >> churros.stats.tsv
done
