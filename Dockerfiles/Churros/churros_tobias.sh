#!/bin/bash
cmdname=`basename $0`
function usage()
{
    echo "$cmdname [Options] <bam> <refpeak> <genome> <label>" 1>&2
    echo '   <bam>: BAM of the ATAC-seq sample' 1>&2
    echo '   <refpeak>: Reference peak file (BED format)' 1>&2
    echo '   <genome>: Genome fasta file' 1>&2
    echo '   <label>: Label of the sample' 1>&2
    echo '   Options:' 1>&2
    echo '      -o <str>: Output directory (default: "tobias")' 1>&2
    echo '      -p <int>: Number of cores to use (default: 4)' 1>&2
}

odir=tobias
ncore=4

motif=/opt/JASPAR/JASPAR2026_CORE_vertebrates_non-redundant_pfms_jaspar.txt

while getopts o:p: option
do
    case ${option} in
        o) odir=${OPTARG};;
        p) ncore=${OPTARG}
           isnumber.sh $ncore "-p" || exit 1
           ;;
        *)
            usage
            exit 1
            ;;
    esac
done
shift $((OPTIND - 1))

if test $# -ne 4; then
    usage
    exit 0
fi

bam=$1
refpeak=$2
genome=$3
label=$4

ex(){ echo $1; eval $1; }

if test -e $bam && test -s $bam ; then
    n=1 # dummy
else
    echo "$bam does not exist."
    exit 1
fi

if test -e $refpeak && test -s $refpeak ; then
    n=1 # dummy
else
    echo "$refpeak does not exist."
    exit 1
fi

if test -e $genome && test -s $genome ; then
    n=1 # dummy
else
    echo "$genome does not exist."
    exit 1
fi

mkdir -p $odir/$label 
refpeak_nochrM=$odir/${label}/refpeak_nochrM.bed
echo "awk 'BEGIN{OFS=\"\\t\"} \$1!=\"chrM\" && \$1!=\"MT\" {print}' \"$refpeak\" > \"$refpeak_nochrM\""
awk 'BEGIN{OFS="\t"} $1!="chrM" && $1!="MT" {print}' "$refpeak" > "$refpeak_nochrM"

ulimit -n 4096

ex "TOBIAS ATACorrect \
  --bam $bam \
  --genome $genome \
  --peaks $refpeak_nochrM \
  --outdir $odir/$label \
  --cores $ncore" \
  2>&1 | tee $odir/${label}/TOBIAS_ATACorrect.log

ex "TOBIAS ScoreBigwig \
  --signal $odir/$label/$label.sort_corrected.bw \
  --regions $refpeak_nochrM \
  --output $odir/$label/${label}_footprints.bw \
  --cores $ncore" \
  2>&1 | tee $odir/${label}/TOBIAS_ScoreBigwig.log

ex "TOBIAS BINDetect \
  --motifs $motif \
  --signals $odir/$label/${label}_footprints.bw \
  --genome $genome \
  --peaks $refpeak_nochrM \
  --cond_names $label \
  --outdir $odir/$label/tobias_bindetect \
  --cores 1" \
  2>&1 | tee $odir/${label}/TOBIAS_BINDetect.log

for logo in CTCF_MA0139.2 `sort -k6,6nr $odir/${label}/tobias_bindetect/bindetect_results.txt | head -n3 | cut -f1`
do
    TOBIAS PlotAggregate \
    --TFBS \
        Churros_result/hg38/tobias/${label}/tobias_bindetect/${logo}/beds/${logo}_all.bed \
        Churros_result/hg38/tobias/${label}/tobias_bindetect/${logo}/beds/${logo}_${label}_bound.bed \
        Churros_result/hg38/tobias/${label}/tobias_bindetect/${logo}/beds/${logo}_${label}_unbound.bed \
    --signals \
        Churros_result/hg38/tobias/${label}/${label}.sort_uncorrected.bw \
        Churros_result/hg38/tobias/${label}/${label}.sort_expected.bw \
        Churros_result/hg38/tobias/${label}/${label}.sort_corrected.bw \
    --output Churros_result/hg38/tobias/${label}/${logo}_footprint_aggregate.pdf \
    --share_y sites \
    --plot_boundaries \
    2>&1 | tee $odir/${label}/TOBIAS_PlotAggregate.$logo.log
done