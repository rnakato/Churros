#!/bin/bash

cmdname=`basename $0`
function usage()
{
    echo "$cmdname <fastqdir> > samplelist.txt" 1>&2
}


if test $# -ne 1; then
    usage
    exit 0
fi


fqdir=$1
for fq in `ls $fqdir/*fastq*`; do
    prefix=`basename $fq .fastq.gz | sed -e 's/.fastq//g'`
    echo -e "$prefix\t$fq"
done
