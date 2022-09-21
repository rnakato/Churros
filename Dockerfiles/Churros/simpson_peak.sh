#!/bin/bash -e
cmdname=`basename $0`
function usage()
{
    echo "$cmdname [Options] <peakfile> <peakfile> ..." 1>&2
    echo '   <peakfile>: peak file (bed format)' 1>&2
    echo '   Options:' 1>&2
    echo '      -n <int>: extract top-<int> peaks for comparison (default: all peaks)' 1>&2
    echo '      -d <str>: output directory (default: "simpson_peak_results/")' 1>&2
    echo '      -v: Draw Venn diagrams for all pairs' 1>&2
    echo '      -p <int>: number of CPUs (default: 8)' 1>&2
}

ncore=8
odir="simpson_peak_results/"
npeak=0
venn=0

while getopts n:d:vp: option
do
    case ${option} in
        n) npeak=${OPTARG}
           isnumber.sh $npeak "-n" || exit 1
           ;;
        d) odir=${OPTARG};;
        v) venn=1;;
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

if test $# -eq 0; then
    usage
    exit 0
fi

peakdir=$odir/Peaks
if test $npeak -gt 0; then
    compdir=$odir/PairwiseComparison/top$npeak
else
    compdir=$odir/PairwiseComparison/allpeaks
fi
mkdir -p $peakdir $compdir
peaklist=$@

array=""
for peak1 in $peaklist; do
    for peak2 in $peaklist; do
        label1=`basename $peak1 _peaks.narrowPeak | sed -e 's/.bed//g'`
        label2=`basename $peak2 _peaks.narrowPeak | sed -e 's/.bed//g'`
        array="$array $peak1,$peak2,$label1,$label2"
    done
done

mkdir -p $odir

ex(){ echo $1; eval $1; }
export -f ex

if test $npeak -gt 0; then
    outputfile=$odir/PeakcomparisonHeatmap.Simpson.top${npeak}peaks.tsv
    for peak1 in $peaklist; do
        label1=`basename $peak1 _peaks.narrowPeak | sed -e 's/.bed//g'`
        ex "grep -v \# $peak1 | head -n$npeak > $peakdir/$label1.top$npeak"
    done
else
    outputfile=$odir/PeakcomparisonHeatmap.Simpson.allpeaks.tsv
fi
rm -rf $outputfile

do_compare_bs(){
    LINE=$1
    npeak=$2
    peakdir=$3
    compdir=$4
    LINE=(${LINE//,/ })
    peak1=${LINE[0]}
    peak2=${LINE[1]}
    label1=${LINE[2]}
    label2=${LINE[3]}

    outfile=$compdir/$label1-$label2.tsv
    if test -e "$outfile"; then
        echo "$outfile already exist. Skipping"
    else
        if test $npeak -gt 0; then
            compare_bs -1 $peakdir/$label1.top$npeak -2 $peakdir/$label2.top$npeak -and > $outfile
        else
            compare_bs -1 $peak1 -2 $peak2 -and > $outfile
        fi
    fi
}
export -f do_compare_bs

echo ${array[@]} | tr ' ' '\n' | xargs -n1 -I {} -P $ncore bash -c "do_compare_bs {} $npeak $peakdir $compdir"
echo "done."

for peak1 in $peaklist; do
    label1=`basename $peak1 _peaks.narrowPeak | sed -e 's/.bed//g'`
    echo -en "\t$label1" >> $outputfile
done
echo "" >> $outputfile

for peak1 in $peaklist; do
    label1=`basename $peak1 _peaks.narrowPeak | sed -e 's/.bed//g'`
    echo -en "$label1" >> $outputfile
    for peak2 in $peaklist; do
        label2=`basename $peak2 _peaks.narrowPeak | sed -e 's/.bed//g'`
        if test $peak1 = $peak2; then
            echo -en "\t1" >> $outputfile
        else
            ntemp=`parsecomparebs.pl $compdir/$label1-$label2.tsv | cut -f4,8 | sed -e 's/(//g' -e 's/)//g' -e 's/%//g'`
            no1=`echo $ntemp | cut -f1 -d" "`
            no2=`echo $ntemp | cut -f2 -d" "`
            if [[ "$no1" == *nan* ]]; then
                no1=0
            fi
            if [[ "$no2" == *nan* ]]; then
                no2=0
            fi
            simpson=`python -c "print('{:.5g}'.format(min([$no1,$no2])/100))"`
            echo -en "\t$simpson" >> $outputfile
        fi
    done
    echo "" >> $outputfile
done

Rscript /opt/Churros/matrix_heatmap.R -i=$outputfile -o=`echo $outputfile | sed 's/.tsv//g'` -clst -fsize=1 -method=ward.D2 -k=2

# draw Venn diagramm
if test $venn = 1; then
    for peak1 in $peaklist; do
        label1=`basename $peak1 _peaks.narrowPeak | sed -e 's/.bed//g'`
        for peak2 in $peaklist; do
            label2=`basename $peak2 _peaks.narrowPeak | sed -e 's/.bed//g'`
            if test $peak1 != $peak2; then
                list=$compdir/$label1-$label2.tsv
                n1=`parsecomparebs.pl $list | cut -f1`
                n2=`parsecomparebs.pl $list | cut -f2`
                o1=`parsecomparebs.pl $list | cut -f3`
                o2=`parsecomparebs.pl $list | cut -f7`
                pdfname=$compdir/$label1-$label2.Venn.pdf
                R -s -e "library(VennDiagram); pdf('$pdfname'); draw.pairwise.venn(area1=$n1, area2=$n2, cross.area=$o2, category=c('$label1','$label2'), cat.pos=c(0,33), cat.dist=c(0.01,0.04), col=c(colors()[139],'blue'), alpha=0.5 , fill=c(colors()[72],'blue'), ext.pos=5); dev.off()"
            fi
        done
    done
fi
