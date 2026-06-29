bam=$1
odir=$2
id=$3

mkdir -p $odir
samtools view -F 0x04 $bam \
        | awk -F'\t' 'function abs(x){return ((x < 0.0) ? -x : x)} {print abs($9)}' \
        | sort | uniq -c | awk -v OFS="\t" '{print $2, $1/2}' \
        > $odir/${id}_fragmentLen.txt
Rscript /opt/SEACR/plot_Fragmentlength.R $odir/${id}_fragmentLen.txt $odir/${id}_fragmentLen.pdf
