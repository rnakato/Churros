#!/bin/bash
cmdname=`basename $0`
function usage()
{
    echo "$cmdname <bam> <output> <build>" 1>&2
    echo '   <bam>: mapfile (BAM format)' 1>&2
    echo '   <output>: output filename' 1>&2
    echo '   <build>: genome build (e.g., hg38)' 1>&2
    echo '   Example:' 1>&2
    echo "      $cmdname ChIP.bam ChIP.FRiR.txt hg38" 1>&2
}

if [ $# -ne 3 ]; then
  usage
  exit 1
fi

bam=$1
output=$2
build=$3

gt=/opt/SSP/data/genometable/genometable.$build.txt
repeat=/opt/RepeatMasker/$build.txt.gz

ex(){ echo $1; eval $1; }

if test ! -e $bam; then
    echo "Error: $bam does not exist."
    exit 1
fi

ex "FRiR -i $bam -o $output --gt $gt -r $repeat"
