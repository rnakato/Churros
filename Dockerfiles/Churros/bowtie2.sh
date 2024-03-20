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
    echo '      -D: output dir (defalt: ./)' 1>&2
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

while getopts cP:p:D: option
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

logdir=$chdir/log/bowtie2
bamdir=$chdir/$bamdir
mkdir -p $logdir $bamdir

if test $format = "BAM"; then
#    file=$bamdir/$prefix$post-$build.sort.bam
    file=$bamdir/$prefix$post.sort.bam
else
 #   file=$bamdir/$prefix$post-$build.sort.cram
    file=$bamdir/$prefix$post.sort.cram
fi

if test -e "$file" && test 1000 -lt `wc -c < $file` ; then
    echo "$file already exist. skipping"
    exit 0
fi

ex(){ echo $1; eval $1; }

ex_hiseq(){
    index=$Ddir/bowtie2-indexes/genome
    genome=$index.fa

    bowtie2 --version

    if test $format = "BAM"; then
        ex "bowtie2 $param -p $ncore -x $index \"$fastq\" | samtools sort > $file"
        if test ! -e $file.bai; then samtools index $file; fi
        else
        ex "bowtie2 $param -p $ncore -x $index \"$fastq\" | samtools view -C - -T $genome | samtools sort -O cram > $file"
        if test ! -e $file.crai; then samtools index $file; fi
    fi

}

ex_hiseq >& $logdir/$prefix.txt
