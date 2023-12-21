#!/bin/bash

cmdname=`basename $0`
function usage()
{
    echo "$cmdname <fastqdir> > samplelist.txt" 1>&2
    echo '   Options:' 1>&2
    echo '      -p: for Paired-end' 1>&2
    echo '      -r: (for Paired-end) postfix is "_R1" and "_R2" (default: "_1" and "_2")' 1>&2
}

pair=0
postfix="_"
while getopts pr option
do
    case ${option} in
        p) pair=1 ;;
        r) postfix="_R" ;;
	*)
	    usage
	    exit 1
	    ;;
    esac
done
shift $((OPTIND - 1))

if test $# -ne 1; then
    usage
    exit 0
fi

fqdir=$1

if test $pair -eq 1; then  # paired-end
    for fq1 in $fqdir/*${postfix}1.{fastq,fastq.gz,fq,fq.gz}; do
        if [[ -f "$fq1" ]]; then
            if [[ "$fq1" == *.fastq.gz ]]; then
                prefix=$(basename "$fq1" .fastq.gz)
            elif [[ "$fq1" == *.fq.gz ]]; then
                prefix=$(basename "$fq1" .fq.gz)
            elif [[ "$fq1" == *.fastq ]]; then
                prefix=$(basename "$fq1" .fastq)
            elif [[ "$fq1" == *.fq ]]; then
                prefix=$(basename "$fq1" .fq)
            else
                prefix=$(basename "$fq1")
            fi

            fq2=`echo $fq1 | sed 's/'${postfix}'1/'${postfix}'2/'`
            echo -e "$prefix\t$fq1\t$fq2"
        fi
    done
else   # single-end
    for fq in $fqdir/*.{fastq,fastq.gz,fq,fq.gz}; do
        if [[ -f "$fq" ]]; then
            if [[ "$fq" == *.fastq.gz ]]; then
                prefix=$(basename "$fq" .fastq.gz)
            elif [[ "$fq" == *.fq.gz ]]; then
                prefix=$(basename "$fq" .fq.gz)
            elif [[ "$fq" == *.fastq ]]; then
                prefix=$(basename "$fq" .fastq)
            elif [[ "$fq" == *.fq ]]; then
                prefix=$(basename "$fq" .fq)
            else
                prefix=$(basename "$fq")
            fi
            echo -e "$prefix\t$fq"
        fi
    done
fi
