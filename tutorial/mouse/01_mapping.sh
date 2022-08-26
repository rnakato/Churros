FASTQ=(
    "fastq/SRR299029.fastq.gz"
    "fastq/SRR299037.fastq.gz"
    "fastq/SRR299038.fastq.gz"
    "fastq/SRR299040.fastq.gz"
    "fastq/SRR299042.fastq.gz"
)

NAME=("CTCF" "H3K4me1" "H3K4me2" "Input" "Pol2")

sing="singularity exec --bind /work,/work2 /work/SingularityImages/churros.0.2.0.sif"
build=mm10
Ddir=Ensembl-GRCm38

# mapping, QC and generate wig files
for ((i=0; i<${#FASTQ[@]}; i++))
do
    echo ${NAME[$i]}
    $sing churros_mapping -m -k 36 exec "${FASTQ[$i]}" ${NAME[$i]} $build $Ddir
done

# output QC stats
$sing churros_mapping -m header "${FASTQ[$i]}" label $build $Ddir > churros.QCstats.tsv
for ((i=0; i<${#FASTQ[@]}; i++))
do
    $sing churros_mapping -m stats "${FASTQ[$i]}" ${NAME[$i]} $build $Ddir >> churros.QCstats.tsv
done
