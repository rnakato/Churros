#!/bin/bash
cmdname=`basename $0`
function usage()
{
    echo "$cmdname [Options] <bam> <prefix> <Ddir>" 1>&2
    echo '   <bam>: mapfile (BAM format)' 1>&2
    echo '   <prefix>: output prefix' 1>&2
    echo '   <Ddir>: Directory of reference genome' 1>&2
    echo '   Options:' 1>&2
    echo '      -o <str>: Output directory (default: current directory)' 1>&2
    echo '      -s <str>: Repeat type ([class|family|name]; default: class)' 1>&2
    echo '   Example:' 1>&2
    echo "      $cmdname ChIP.bam ChIP.FRiR.txt Referencedata_hg38" 1>&2
}

output_dir="."
repeattype="class"
while getopts o:s: option
do
    case ${option} in
        o) output_dir=${OPTARG};;
        s) repeattype=${OPTARG};;
        *)
            usage
            exit 1
            ;;
    esac
done
shift $((OPTIND - 1))

if [ $# -ne 3 ]; then
  usage
  exit 1
fi

bam=$1
prefix=$2
Ddir=$3

gt=$Ddir/genometable.txt
repeat=$Ddir/RepeatMasker.UCSC.txt.gz

ex(){ echo $1; eval $1; }

if test ! -e $bam; then
    echo "Error: $bam does not exist."
    exit 1
fi

if test ! -e $repeat; then
    echo "Error: $repeat does not exist."
    exit 1
fi

if test ! -e $gt; then
    echo "Error: $gt does not exist."
    exit 1
fi

ex "FRiR -i $bam -o $output_dir/$prefix --gt $gt -r $repeat --repeattype $repeattype"

