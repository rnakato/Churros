#!/bin/bash
cmdname=`basename $0`
function usage()
{
    echo "$cmdname [Options] <fastq> <prefix> <Ddir>" 1>&2
    echo '   <fastq>: fastq file' 1>&2
    echo '   <prefix>: output prefix' 1>&2
    echo '   <Ddir>: directory of bowtie2 index' 1>&2
    echo '   Options:' 1>&2
    echo '      -c: output as CRAM format (defalt: BAM)' 1>&2
    echo '      -p: number of CPUs (default: 12)' 1>&2
    echo '      -P "bowtie2 param": parameter of bowtie2 (shouled be quated)' 1>&2
    echo '      -D: output dir (defalt: "./")' 1>&2
    echo '      -B: Directory for BAM/CRAM files (defalt: "bam/ or cram/")' 1>&2
    echo '      -L: Log directory of bowtie2 (default: "bowtie2")' 1>&2
    echo '      -x: do not output mapped file (statistics only, for spike-in genome)' 1>&2
    echo "   Example:" 1>&2
    echo "      For single-end: $cmdname -p \"--very-sensitive\" chip.fastq.gz chip Referencedata_hg38" 1>&2
    echo "      For paired-end: $cmdname \"\-1 chip_1.fastq.gz \-2 chip_2.fastq.gz\" chip Referencedata_hg38" 1>&2
}

#echo $cmdname $*

format=BAM
bamdir=bam
param=""
ncore=12
chdir="./"
no_output=0
logdir="bowtie2"

while getopts cP:p:D:B:L:x option
do
    case ${option} in
	c) format=CRAM
        bamdir=cram
        ;;
    p) ncore=${OPTARG}
        isnumber.sh $ncore "-p" || exit 1
        ;;
	P) param=${OPTARG};;
    D) chdir=${OPTARG};;
    B) bamdir=${OPTARG};;
	L) logdir=${OPTARG};;
    x) no_output=1;;
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

fastq=$1
prefix=$2
Ddir=$3
#post=`echo $param | tr -d ' ' | sed -e 's/--/-/g'`

logdir=$chdir/log/$logdir
bamdir=$chdir/$bamdir
mkdir -p $logdir $bamdir

if test $format = "BAM"; then
#    file=$bamdir/$prefix$post-$build.sort.bam
    file=$bamdir/$prefix$post.sort.bam
else
 #   file=$bamdir/$prefix$post-$build.sort.cram
    file=$bamdir/$prefix$post.sort.cram
fi

ex(){ echo $1; eval $1; }

ex_hiseq(){
    index=$Ddir/bowtie2-indexes/genome
    genome=$index.fa

    bowtie2 --version

    if test $no_output -eq 1; then
        ex "bowtie2 $param -p $ncore -x $index \"$fastq\" > /dev/null"
    elif test $format = "BAM"; then
        ex "bowtie2 $param -p $ncore -x $index \"$fastq\" | samtools sort > $file"
        if test ! -e $file.bai; then samtools index $file; fi
    else
        ex "bowtie2 $param -p $ncore -x $index \"$fastq\" | samtools view -C - -T $genome | samtools sort -O cram > $file"
        if test ! -e $file.crai; then samtools index $file; fi
    fi
}

#if test -e "$file" && test 1000 -lt `wc -c < $file` ; then
#    echo "$file already exist. skipping"
#    exit 0
#fi

logfile=$logdir/$prefix.txt
#if test -e $logfile; then
#    echo "$logfile already exist. skipping"

if test -e "$file" && test 1000 -lt `wc -c < $file` ; then
    echo "$file already exist. skipping"
else
    ex_hiseq >& $logfile
fi