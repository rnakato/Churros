#!/bin/bash
cmdname=`basename $0`
function usage()
{
    echo "$cmdname [Options] <IP bam> <Input bam> <prefix> <build> <mode>" 1>&2
    echo '   <IP bam>: BAM for for ChIP (treat) sample' 1>&2
    echo '   <Input bam>: BAM for for Input (control) sample: specify "none" if unavailable' 1>&2
    echo '   <prefix>: prefix of output file' 1>&2
    echo '   <build>: genome build (e.g., hg38)' 1>&2
    echo '   <mode>: peak mode ([sharp|broad|sharp-nomodel|broad-nomodel])' 1>&2
    echo '   Options:' 1>&2
    echo '      -f <int>: predefined fragment length (defalt: estimated in MACS2)' 1>&2
    echo '      -d <str>: output directory (defalt: "macs")' 1>&2
    echo '      -B: save extended fragment pileup, and local lambda tracks (two files) at every bp into a bedGraph file' 1>&2
    echo '      -F: overwrite files if exist (defalt: skip)' 1>&2
}

flen=200
qval=0.05
mdir=macs
force=0
param_bdg=""

while getopts f:q:d:BF option
do
    case ${option} in
	f) flen=${OPTARG};;
	q) qval=${OPTARG};;
	d) mdir=${OPTARG};;
	B) param_bdg="-B";;
	F) force=1;;
	*)
	    usage
	    exit 1
	    ;;
    esac
done
shift $((OPTIND - 1))

if test $# -ne 5; then
    usage
    exit 0
fi

IP=$1
Input=$2
prefix=$3
build=$4
mode=$5

ex(){ echo $1; eval $1; }

if test $build = "hg19" -o $build = "hg38" -o $build = "T2T"; then
    sp="hs"
elif test $build = "mm9" -o $build = "mm10" -o $build = "mm39"; then
    sp="mm"
elif test $build = "ce11"; then
    sp="ce"
elif test $build = "dm3" -o $build = "dm6" -o $build = "dm7"; then
    sp="dm"
elif test $build = "sacCer3" -o $build = "Spom"; then
    sp="13e6"
    param_yeast="--keep-dup all"
else
    sp="1e8"
fi

if test -e $IP && test -s $IP ; then
    n=1 # dummy
else
    echo "$IP does not exist."
fi

if test $Input = "none"; then
    macs="macs2 callpeak -t $IP -g $sp -f BAM -q $qval $param_bdg $param_yeast"
else
    macs="macs2 callpeak -t $IP -c $Input -g $sp -f BAM $param_bdg $param_yeast"
    if test -e $Input && test -s $Input; then
        n=1 # dummy
    else
        echo "$Input does not exist."
    fi
fi

param_sharp=""
param_broad="--broad-cutoff 0.1"

mkdir -p $mdir

if test $mode = "sharp" -o $mode = "sharp-nomodel"; then
    peak=$mdir/${prefix}_peaks.narrowPeak
else
    peak=$mdir/${prefix}_peaks.broadPeak
fi

if test -e "$peak" -a $force -eq 0 ; then
    echo "$peak already exist. Skipping"
else
    logfile=$mdir/$prefix.$mode.log
    if test $mode = "sharp"; then
	ex "$macs $param_sharp -n $mdir/$prefix >& $logfile"
    elif test $mode = "sharp-nomodel"; then
    	ex "$macs $param_sharp -n $mdir/$prefix --nomodel --extsize `expr ${flen} / 2` >& $logfile"
    elif test $mode = "broad"; then
    	ex "$macs $param_broad -n $mdir/$prefix --broad >& $logfile"
    elif test $mode = "broad-nomodel"; then
    	ex "$macs $param_broad -n $mdir/$prefix --broad --nomodel --extsize `expr ${flen} / 2` >& $logfile"
    else
	echo "Error: specify [sharp|broad|sharp-nomodel|broad-nomodel] for mode."
	exit 1
    fi
fi
