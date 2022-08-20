FASTQ=(
    "fastq/SRR13065962.fastq.gz"
    "fastq/SRR13065963.fastq.gz"
    "fastq/SRR13065966.fastq.gz"
    "fastq/SRR13065967.fastq.gz"
    "fastq/SRR13065972.fastq.gz"
    "fastq/SRR13065973.fastq.gz"
    "fastq/SRR13065974.fastq.gz"
    "fastq/SRR13065975.fastq.gz"
)

NAME=(
    "Scc1_DMSO"
    "Input_Scc1_DMSO"
    "Scc1_thiolutin"
    "Input_Scc1_thiolutin"
    "RPO21_DMSO"
    "Input_RPO21_DMSO"
    "RPO21_thiolutin"
    "InputRPO21_thiolutin"
)

sing="singularity exec --bind /work,/work2 /work/SingularityImages/churros.0.2.0.sif"
build=sacCer3
Ddir=Ensembl-R64-1-1

# mapping, QC and generate wig files
for ((i=0; i<${#FASTQ[@]}; i++))
do
    echo ${NAME[$i]}
    $sing churros_mapping exec "${FASTQ[$i]}" ${NAME[$i]} $build $Ddir
done

# output QC stats
$sing churros_mapping header "${FASTQ[$i]}" label $build $Ddir > churros.QCstats.tsv
for ((i=0; i<${#FASTQ[@]}; i++))
do
    $sing churros_mapping stats "${FASTQ[$i]}" ${NAME[$i]} $build $Ddir >> churros.QCstats.tsv
done
