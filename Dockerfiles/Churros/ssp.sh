#!/bin/bash
cmdname=`basename $0`
function usage()
{
    echo "$cmdname [-k kmer] [-o dir] [-p] <mapfile> <prefix> <build> <genometable>" 1>&2
    echo '   <mapfile>: mapfile (SAM|BAM|CRAM|TAGALIGN format)' 1>&2
    echo '   <prefix>: output prefix' 1>&2
    echo '   <build>: genome build (e.g., hg38)' 1>&2
    echo '   <genometable>: genome table file' 1>&2
    echo '   Options:' 1>&2
    echo '      -k: read length (36 or 50) for mappability calculation (default: 50)' 1>&2
    echo '      -p: for paired-end file' 1>&2
    echo '      -o: output directory (default: sspout)' 1>&2
    echo '      -t: number of CPUs (default: 4)' 1>&2
    echo '      -D outputdir: output dir (defalt: ./)' 1>&2
    echo "   Example:" 1>&2
    echo "      For single-end: $cmdname chip.sort.bam chip hg38 genometable.hg38.txt" 1>&2
    echo "      For single-end: $cmdname -p chip.sort.bam chip hg38 genometable.hg38.txt" 1>&2
}

k=50
odir=sspout
pair=""
ncore=4
chdir="./"

while getopts k:o:pt:D: option
do
    case ${option} in
	k) k=${OPTARG};;
	o) odir=${OPTARG};;
	p) pair="--pair";;
	t) ncore=${OPTARG};;
        D) chdir=${OPTARG};;
        *)
	    usage
	    exit 1
	    ;;
    esac
done
shift $((OPTIND - 1))

if [ $# -ne 4 ]; then
  usage
  exit 1
fi
input=$1
prefix=$2
build=$3
gt=$4

odir=$chdir/$odir

ex(){ echo $1; eval $1; }

logdir=$chdir/log/ssp
mkdir -p $logdir

param=""
if test $build = "scer" -o $build = "pombe" -o $build = "sacCer3" -o $build = "Spom"; then
    param="--ng_from 10000 --ng_to 50000 --ng_step 500"
else
    param=""
fi

mptable=/opt/SSP/data/mptable/mptable.UCSC.$build.${k}mer.flen150.txt

echo "Quality check of $input by ssp."

if test -e $input && test -s $input ; then
    if test ! -e $odir/$prefix.stats.txt ; then
	ex "ssp $param $pair -i $input -o $prefix --odir $odir --gt $gt --mptable $mptable -p $ncore >& $logdir/$prefix.txt"
    fi
else
    echo "$input does not exist."
fi

echo "ssp.sh done."
