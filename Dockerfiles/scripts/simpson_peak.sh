#!/bin/bash -e
cmdname=`basename $0`
function usage()
{
    echo "$cmdname [Options] <peakfile> <peakfile> ..." 1>&2
    echo '   <peakfile>: peak file (bed format)' 1>&2
    echo '   Options:' 1>&2
    echo '      -d : output directory (default: current directory)' 1>&2
    echo '      -p : number of CPUs (default: 8)' 1>&2
}

ncore=8
odir="simpson_peak_results/"

while getopts d:p: option
do
    case ${option} in
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

peaklist=$@

array=""
for peak1 in $peaklist; do
    for peak2 in $peaklist; do
        array="$array $peak1,$peak2"
    done
done

mkdir -p $odir
outputfile=$odir/simpson_peak.tsv
touch $outputfile

ex(){ echo $1; eval $1; }
export -f ex

do_compare_bs(){
    LINE=$1
    LINE=(${LINE//,/ })
    peak1=${LINE[0]}
    peak2=${LINE[1]}
    ex " compare_bs -1 $peak1 -2 $peak2 -and > $odir/compare_bs-$peak1-$peak2"
}
export -f do_compare_bs

ncore=8
echo ${array[@]} | tr ' ' '\n' | xargs -n1 -I {} -P $ncore bash -c "do_compare_bs {}"

for peak1 in $peaklist; do
    echo -en "\t$peak1" >> $outputfile
done
echo "" >> $outputfile

for peak1 in $peaklist; do
    echo -en "$peak1" >> $outputfile
    for peak2 in $peaklist; do
	n1=`wc -l $peak1 | cut -f1 -d" "`
	n2=`wc -l $peak2 | cut -f1 -d" "`
	ntemp=`parsecomparebs.pl $odir/compare_bs-$peak1-$peak2 | cut -f4,8 | sed -e 's/(//g' -e 's/)//g' -e 's/%//g'`
	no1=`echo $ntemp | cut -f1 -d" "`
	no2=`echo $ntemp | cut -f2 -d" "`
	simpson=`python -c "print(min([$no1,$no2]))"`
	echo -en "\t$simpson" >> $outputfile
    done
    echo "" >> $outputfile
done
