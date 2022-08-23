#!/bin/bash -e
cmdname=`basename $0`
function usage()
{
    echo "$cmdname [Options] <peakfile> <peakfile> ..." 1>&2
    echo '   <peakfile>: peak file (bed format)' 1>&2
    echo '   Options:' 1>&2
    echo '      -n <int>: extract top-<int> peaks for comparison (default: all peaks)' 1>&2
    echo '      -d <str>: output directory (default: "simpson_peak_results/")' 1>&2
    echo '      -p <int>: number of CPUs (default: 4)' 1>&2
}

ncore=4
odir="simpson_peak_results/"
npeak=0

while getopts n:d:p: option
do
    case ${option} in
        n) npeak=${OPTARG};;
        d) odir=${OPTARG};;
        p) ncore=${OPTARG};;
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

mkdir -p $odir
peaklist=$@

array=""
for peak1 in $peaklist; do
    for peak2 in $peaklist; do
        label1=`basename $peak1`
        label2=`basename $peak2`
        array="$array $peak1,$peak2,$label1,$label2"
    done
done

mkdir -p $odir

ex(){ echo $1; eval $1; }
export -f ex

if test $npeak -gt 0; then
    outputfile=$odir/simpson_peak.top${npeak}peaks.tsv
    for peak1 in $peaklist; do
        label1=`basename $peak1`
        ex "grep -v \# $peak1 | head -n$npeak > $odir/$label1.top$npeak"
    done
else
    outputfile=$odir/simpson_peak.allpeaks.tsv
fi
rm -rf $outputfile

do_compare_bs(){
    LINE=$1
    npeak=$2
    odir=$3
    LINE=(${LINE//,/ })
    peak1=${LINE[0]}
    peak2=${LINE[1]}
    label1=${LINE[2]}
    label2=${LINE[3]}

    if test $npeak -gt 0; then
#        grep -v \# $peak1 | head -n$npeak > $odir/$label1.top$npeak
#        grep -v \# $peak2 | head -n$npeak > $odir/$label2.top$npeak
        ex " compare_bs -1 $odir/$label1.top$npeak -2 $odir/$label2.top$npeak -and > $odir/compare_bs-$label1-$label2.top$npeak"
    else
        ex " compare_bs -1 $peak1 -2 $peak2 -and > $odir/compare_bs-$label1-$label2"
    fi
}
export -f do_compare_bs

ncore=8
echo ${array[@]} | tr ' ' '\n' | xargs -n1 -I {} -P $ncore bash -c "do_compare_bs {} $npeak $odir"

for peak1 in $peaklist; do
    label1=`basename $peak1`
    echo -en "\t$label1" >> $outputfile
done
echo "" >> $outputfile

for peak1 in $peaklist; do
    label1=`basename $peak1`
    echo -en "$label1" >> $outputfile
    for peak2 in $peaklist; do
        label2=`basename $peak2`
        if test $npeak -gt 0; then
            ntemp=`parsecomparebs.pl $odir/compare_bs-$label1-$label2.top$npeak | cut -f4,8 | sed -e 's/(//g' -e 's/)//g' -e 's/%//g'`
        else
            ntemp=`parsecomparebs.pl $odir/compare_bs-$label1-$label2           | cut -f4,8 | sed -e 's/(//g' -e 's/)//g' -e 's/%//g'`
        fi
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
    done
    echo "" >> $outputfile
done

# draw Venn diagramm
for peak1 in $peaklist; do
    label1=`basename $peak1`
    for peak2 in $peaklist; do
        label2=`basename $peak2`
        if test $npeak -gt 0; then
	    list=$odir/compare_bs-$label1-$label2.top$npeak
	    pdfname=$odir/Venn-$label1-$label2.top$npeak.pdf
        else
            list=$odir/compare_bs-$label1-$label2
	    pdfname=$odir/Venn-$label1-$label2.all.pdf
        fi
	n1=`parsecomparebs.pl $list | cut -f1`
	n2=`parsecomparebs.pl $list | cut -f2`
	o1=`parsecomparebs.pl $list | cut -f3`
	o2=`parsecomparebs.pl $list | cut -f7`

	R -e "library(VennDiagram); pdf('$pdfname'); draw.pairwise.venn(area1=$n1, area2=$n2, cross.area=$o2, category=c('$label1','$label2'), cat.pos=c(0,33), cat.dist=c(0.01,0.04), col=c(colors()[139],'blue'), alpha=0.5 , fill=c(colors()[72],'blue'), ext.pos=5); dev.off()"
	rm temp

    done
done
