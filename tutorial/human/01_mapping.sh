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

#sing="singularity exec --bind /work,/work2 /work/SingularityImages/churros.0.2.0.sif"
sing="singularity exec churros.0.2.0.sif"
builsd=hg38
Ddir=Ensembl-GRCh38

# mapping, QC and generate wig files
# supply '-m' option to consider genome mappability
for ((i=0; i<${#FASTQ[@]}; i++))
do
    echo ${NAME[$i]}
    $sing churros_mapping -m -k 36 exec "${FASTQ[$i]}" ${NAME[$i]} $build $Ddir
done

$sing churros_mapping -m header "${FASTQ[$i]}" label $build $Ddir > churros.QCstats.tsv
for ((i=0; i<${#FASTQ[@]}; i++))
do
    $sing churros_mapping -m stats "${FASTQ[$i]}" ${NAME[$i]} $build $Ddir >> churros.QCstats.tsv
done
