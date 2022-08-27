#!/bin/bash
cmdname=`basename $0`
function usage()
{
    echo "$cmdname [Options] <fastq> <prefix> <build> <Ddir>" 1>&2
    echo '   <fastq>: fastq file' 1>&2
    echo '   <prefix>: output prefix' 1>&2
    echo '   <build>: genome build (e.g., hg38)' 1>&2
    echo '   <Ddir>: directory of bowtie index' 1>&2
    echo '   Options:' 1>&2
    echo '      -t STR: for SOLiD data ([fastq|csfata|csfastq], defalt: fastq)' 1>&2
    echo '      -c: output as CRAM format (defalt: BAM)' 1>&2
    echo '      -p INT: number of CPUs (default: 12)' 1>&2
    echo '      -P "STR": parameter of bowtie (shouled be quated, default: "-n2 -m1")' 1>&2
    echo '      -D: output dir (defalt: ./)' 1>&2
    echo "   Example:" 1>&2
    echo "      For single-end: $cmdname -P \"-n2 -m1\" chip.fastq.gz chip hg38 Ensembl-GRCh38" 1>&2
    echo "      For paired-end: $cmdname \"\-1 chip_1.fastq.gz \-2 chip_2.fastq.gz\" chip hg38 Ensembl-GRCh38" 1>&2
    echo "      For SOLiD data: $cmdname -t csfastq -P \"-n2 -m1\" chip.csfastq.gz chip hg38 Ensembl-GRCh38" 1>&2
}

type=fastq
format=BAM
bamdir=bam
ncore=12
chdir="./"
param=""

while getopts ct:P:p:D: option
do
    case ${option} in
        c) format=CRAM
           bamdir=cram
           ;;
        t) type=${OPTARG};;
        p) ncore=${OPTARG};;
        P) param=${OPTARG};;
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

fastq=$1
prefix=$2
build=$3
Ddir=$4
post="-bowtie"`echo $param | tr -d ' '`

logdir=$chdir/log/bowtie
bamdir=$chdir/$bamdir
mkdir -p $logdir $bamdir


if test $format = "BAM"; then
    file=$bamdir/$prefix$post-$build.sort.bam
else
    file=$bamdir/$prefix$post-$build.sort.cram
fi

if test -e $file && test 1000 -lt `wc -c < $file` ; then
    echo "$file already exist. quit"
    exit 0
fi

ex(){ echo $1; eval $1; }

ex_hiseq(){
    index=$Ddir/bowtie-indexes/genome
    genome=$Ddir/genome.fa

    bowtie --version

    if [[ $fastq = *.gz ]]; then
	fastq="<(zcat `echo $fastq | sed -e 's/,/\t/g'`)"
    fi

    if test $format = "BAM"; then
	ex "bowtie -S $index $fastq $param --chunkmbs 2048 -p $ncore | samtools sort > $file"
        if test ! -e $file.bai; then samtools index $file; fi
    else
	ex "bowtie -S $index $fastq $param --chunkmbs 2048 -p $ncore | samtools view -C - -T $genome | samtools sort -O cram > $file"
        if test ! -e $file.crai; then samtools index $file; fi
    fi
}

ex_csfasta(){
    # bowtie-1.2.2 has a bug for csfasta
    # use bowtie-1.1.2

    index=$Ddir/bowtie-indexes/genome-cs
    genome=$Ddir/genome.fa

    bowtie=/opt/bowtie-1.1.2/bowtie
    $bowtie --version

    csfasta=`ls $fastq*csfasta*`
    qual=`ls $fastq*qual*`

    if [[ $csfasta = *.gz ]]; then
	csfasta="<(zcat `echo $csfasta | sed -e 's/,/\t/g'`)"
	qual="<(zcat `echo $qual | sed -e 's/,/\t/g'`)"
    fi

    if test $format = "BAM"; then
	ex "$bowtie -S -C $index -f $csfasta -Q $qual $param --chunkmbs 2048 -p $ncore | samtools sort > $file"
        if test ! -e $file.bai; then samtools index $file; fi
    else
	ex "$bowtie -S -C $index -f $csfasta -Q $qual $param --chunkmbs 2048 -p $ncore | samtools view -C - -T $genome | samtools sort -O cram > $file"
        if test ! -e $file.crai; then samtools index $file; fi
    fi
}

ex_csfastq(){
    index=$Ddir/bowtie-indexes/genome-cs
    genome=$Ddir/genome.fa

    bowtie=/opt/bowtie-1.1.2/bowtie
    $bowtie --version

    if [[ $fastq = *.gz ]]; then
	fastq="<(zcat `echo $fastq | sed -e 's/,/\t/g'`)"
    fi

    if test $format = "BAM"; then
        ex "$bowtie -S -C $index $fastq $param --chunkmbs 2048 -p $ncore | samtools sort > $file"
        if test ! -e $file.bai; then samtools index $file; fi
    else
        ex "$bowtie -S -C $index $fastq $param --chunkmbs 2048 -p $ncore | samtools view -C - -T $genome | samtools sort -O cram > $file"
        if test ! -e $file.crai; then samtools index $file; fi
    fi
}

log=$logdir/bowtie-$prefix$post-$build
if test $type = "csfasta"; then  ex_csfasta >& $log;
elif test $type = "csfastq"; then  ex_csfastq >& $log;
else ex_hiseq >& $log
fi
