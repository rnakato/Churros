#!/bin/bash
cmdname=`basename $0`
function usage()
{
    echo "$cmdname [Options] <fastq> <prefix> <build> <Ddir>" 1>&2
    echo '   <fastq>: fastq file' 1>&2
    echo '   <prefix>: output prefix' 1>&2
    echo '   <build>: genome build (e.g., hg38)' 1>&2
    echo '   <Ddir>: directory of bowtie2 index' 1>&2
    echo '   Options:' 1>&2
    echo '      -b: output as BAM format (default: CRAM)' 1>&2
#    echo '      -d: output directory of mapfiles (default: cram)' 1>&2
    echo '      -p "bowtie2 param": parameter of bowtie2 (shouled be quated)' 1>&2
    echo "   Example:" 1>&2
    echo "      For single-end: $cmdname -p \"--very-sensitive\" chip.fastq.gz chip hg38" 1>&2
    echo "      For paired-end: $cmdname \"\-1 chip_1.fastq.gz \-2 chip_2.fastq.gz\" chip hg38" 1>&2
}

echo $cmdname $*

type=hiseq
bamdir=cram
param=""
outputbam=false

while getopts bd:p: option
do
    case ${option} in
	d)
	    outputbam=true
	    bamdir=bam
	    ;;
	d) bamdir=${OPTARG};;
        p) param=${OPTARG};;
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

fastq=$1
prefix=$2
build=$3
Ddir=$4
post="-bowtie2"`echo $param | tr -d ' '`

if test ! -e $bamdir; then mkdir $bamdir; fi
if test ! -e log; then mkdir log; fi

if test $outputbam = "true"; then
    file=$bamdir/$prefix$post-$build.sort.bam
else
    file=$bamdir/$prefix$post-$build.sort.cram
fi

if test -e "$file" && test 1000 -lt `wc -c < $file` ; then
    echo "$file already exist. quit"
    exit 0
fi

ex(){ echo $1; eval $1; }

ex_hiseq(){
    index=$Ddir/bowtie2-indexes/genome
    genome=$index.fa

    bowtie2 --version

    if test $outputbam = "true"; then
	command="bowtie2 $param -p12 -x $index \"$fastq\" | samtools sort > $file"
	ex $command
	if test ! -e $file.bai; then samtools index $file; fi
    else
	command="bowtie2 $param -p12 -x $index \"$fastq\" | samtools view -C - -T $genome | samtools sort -O cram > $file"
	ex $command
	if test ! -e $file.crai; then samtools index $file; fi
    fi

}

log=log/bowtie2-$prefix$post-$build
ex_hiseq >& $log
