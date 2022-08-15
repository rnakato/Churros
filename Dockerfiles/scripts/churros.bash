#!/bin/bash
cmdname=`basename $0`
function usage()
{
    echo "$cmdname [options] <samplelist> <samplepairlist> <build> <Ddir>" 1>&2
    echo '   <samplelist>: sample list' 1>&2
    echo '   <samplepairlist>: ChIP/Input pair list' 1>&2
    echo '   <build>: genome build (e.g., hg38)' 1>&2
    echo '   <Ddir>: directory of bowtie2 index' 1>&2
    echo '   Options:' 1>&2
    echo '      -c: output as CRAM format (defalt: BAM)' 1>&2
    echo '      -b: binsize of parse2wig+ (defalt: 100)' 1>&2
    echo '      -m: consider genome mappability in parse2wig+' 1>&2
    echo '      -n: omit ssp' 1>&2
    echo '      -q <qvalue>: threshould of MACS2 (defalt: 0.05)' 1>&2
    echo '      -d <mdir>: output direcoty of macs2 (defalt: "macs")' 1>&2
    echo '      -f: output format of parse2wig+ (default: 3)' 1>&2
    echo '               0: compressed wig (.wig.gz)' 1>&2
    echo '               1: uncompressed wig (.wig)' 1>&2
    echo '               2: bedGraph (.bedGraph)' 1>&2
    echo '               3: bigWig (.bw)' 1>&2
    echo '      -P "bowtie2 param": parameter of bowtie2 (shouled be quated)' 1>&2
    echo '      -p : number of CPUs (default: 12)' 1>&2
    echo '      -w : output ChIP/Input -log(p) distribution as a begraph format' 1>&2
    echo '      -D outputdir: output dir (defalt: "Churros_result")' 1>&2
    echo "   Example:" 1>&2
    echo "      For single-end: $cmdname exec chip.fastq.gz chip hg38 Database/Ensembl-GRCh38" 1>&2
}

bowtieparam=""
mp=0
nopp=0
format=BAM
bamdir=bam
of=3
binsize=100
outputpval=0
ncore=12

qval=0.05
mdir=macs

chdir="Churros_result"

while getopts cb:mnf:P:p:q:d:wD: option
do
    case ${option} in
	c) format=CRAM
	   bamdir=cram
	   ;;
	b) binsize=${OPTARG};;
        m) mp=1;;
        n) nopp=1;;
        f) of=${OPTARG};;
        P) bowtieparam=${OPTARG};;
        p) ncore=${OPTARG};;
	q) qval=${OPTARG};;
        d) mdir=${OPTARG};;
	w) outputpval=1;;
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

samplelist=$1
samplepairlist=$2
build=$3
Ddir=$4

if test ! -e $samplelist; then
    echo "Error: $samplelist does not exist."
    exit 1
fi
if test ! -e $samplepairlist; then
    echo "Error: $samplepairlist does not exist."
    exit 1
fi


if [[ ${samplelist} =~ ^/.+$ ]]; then
    n=1 # dummy
else
    samplelist=$(pwd)/$samplelist
fi
if [[ ${samplepairlist} =~ ^/.+$ ]]; then
    n=1 # dummy
else
    samplepairlist=$(pwd)/$samplepairlist
fi


post="-bowtie2"`echo $bowtieparam | tr -d ' '`

if test $mp -eq 1; then
    parseparam="-m"
    pdfparam="-m"
else
    parseparam=""
    pdfparam=""
fi

mkdir -p $chdir

### FASTQC
mkdir -p $chdir/fastqc
while read LINE; do
    LINE=($LINE)
    prefix=${LINE[0]}
    fq1=${LINE[1]}
    fq2=${LINE[2]}
    fqarray=`echo $fq1 $fq2 | sed -e "s/,/ /g"`
    for fq in $fqarray
    do
	fastqc -t 4 -o $chdir/fastqc $fq
    done
done < $samplelist
rm $chdir/fastqc/*fastqc.zip

### mapping
while read LINE; do
    LINE=($LINE)
    prefix=${LINE[0]}
    fq1=${LINE[1]}
    fq2=${LINE[2]}
    head=$prefix$post-$build

    if test "$fq1" = ""; then
	echo "Error: specify fastq file in $samplelist."
	exit
    fi
    # for paired-end fastq
    pair=""
    if test "$fq2" != ""; then
	pair="-p"
	fastq="-1 $fq1 -2 $fq2"
    else
	fastq="$fq1"
    fi
    churros_mapping -D $chdir -p $ncore $parseparam exec "$fastq" $prefix $build $Ddir
done < $samplelist

churros_mapping -D $chdir header $parseparam "$fastq" $prefix $build $Ddir > $chdir/churros.QCstats.tsv
while read LINE; do
    LINE=($LINE)
    prefix=${LINE[0]}
    fq1=${LINE[1]}
    churros_mapping -D $chdir $parseparam stats $fq1 $prefix $build $Ddir >> $chdir/churros.QCstats.tsv
done < $samplelist

samplepairlist_withflen=$chdir/churros.samplepairlist.withflen.txt
rm $samplepairlist_withflen
post="-bowtie2"`echo $bowtieparam | tr -d ' '`
while read LINE; do
    LINE=(${LINE//,/ })
    chip=${LINE[0]}
    input=${LINE[1]}
    label=${LINE[2]}
    mode=${LINE[3]}
    flen=`cut -f5 $chdir/sspout/${chip}$post-$build.stats.txt | tail -n1`
    echo "$chip,$input,$label,$mode,$flen" >> $samplepairlist_withflen
done < $samplepairlist

if test ! -e $samplepairlist_withflen; then
   churros_callpeak -b bam -p $ncore -q $qval -d $mdir $samplepairlist $build
else
   churros_callpeak -b bam -p $ncore -q $qval -d $mdir $samplepairlist_withflen $build
fi


### MultiQC
multiqc $chdir/

### generate P-value bedGraph
if test $outputpval -eq 1; then
    echo "generate Pvalue bedGraph file..."
    gt=$Ddir/genometable.txt
    churros_genPvalwig -D $chdir $samplepairlist drompa+.pval $build $gt
fi


### make pdf files
echo "generate pdf files by drompa+..."
if test $mp -eq 1; then
    pdfparam="-D $chdir -m"
else
    pdfparam="-D $chdir"
fi
pdfdir=pdf
churros_visualize $pdfparam $chdir/$mdir/samplepairlist.txt $pdfdir/drompa+.macspeak $build $Ddir
churros_visualize $pdfparam -b 5000 -l 8000 -P "--scale_tag 100" $samplepairlist $pdfdir/drompa+.bin5M $build $Ddir
churros_visualize $pdfparam -b 5000 -l 8000 -p -P "--pthre_enrich 3 --scale_pvalue 3" $samplepairlist $pdfdir/drompa+.pval.bin5M $build $Ddir
churros_visualize $pdfparam -G $samplepairlist $pdfdir/drompa+ $build $Ddir
echo "done."
