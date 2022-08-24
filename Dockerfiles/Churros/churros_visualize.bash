#!/bin/bash
cmdname=`basename $0`
function usage()
{
    echo "$cmdname [Options] <samplepairlist> <prefix> <build> <Ddir>" 1>&2
    echo '   <samplepairlist>: text file of ChIP/Input sample pairs' 1>&2
    echo '   <prefix>: output prefix (directory will be omitted)' 1>&2
    echo '   <build>: genome build (e.g., hg38)' 1>&2
    echo '   <Ddir>: directory of bowtie2 index' 1>&2
    echo '   Options:' 1>&2
    echo '      -f <int>: Input file format (default: 3)' 1>&2
    echo '                 0: compressed wig (.wig.gz)' 1>&2
    echo '                 1: uncompressed wig (.wig)' 1>&2
    echo '                 2: bedGraph (.bedGraph)' 1>&2
    echo '                 3: bigWig (.bw)' 1>&2
    echo '      -b <int>: binsize (defalt: 100)' 1>&2
    echo '      -l <int>: line size for each page (defalt: 1000 (kbp))' 1>&2
    echo '      -m: consider genome mappability in parse2wig+' 1>&2
    echo '      -d <str>: directory of parse2wig+ (default: parse2wigdir+)' 1>&2
    echo '      -y: S. cerevisiae mode (PC_ENRICH for 100-bp bin)' 1>&2
    echo '      -s <str>: param string of parse2wig+ files to be used (default: "-bowtie2-<build>-raw-GR")' 1>&2
    echo '      -p: show p-value distribution instead of read distribution' 1>&2
    echo '      -P: additional parameters for DROMPA+ (shouled be quated)' 1>&2
    echo '      -G: genome-wide view (100kbp)' 1>&2
    echo '      -D: directory for execution (defalt: "Churros_result")' 1>&2
    echo "   Example:" 1>&2
    echo "      $cmdname samplelist.txt chip-seq hg38 Database/Ensembl-GRCh38" 1>&2
}

binsize=100
linesize=1000
pdir=parse2wigdir+
post_predefined=""
GV=0
showpvalue=0
mp=0
yeast=0
param=""
chdir="Churros_result"
wigformat=3

while getopts f:P:b:l:myd:o:s:pGD: option
do
    case ${option} in
        f) wigformat=${OPTARG};;
        P) param=${OPTARG};;
        b) binsize=${OPTARG};;
        l) linesize=${OPTARG};;
        m) mp=1;;
        y) yeast=1;;
        d) pdir=${OPTARG};;
        s) post_predefined=${OPTARG};;
	p) showpvalue=1;;
        G) GV=1;;
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

samplepairlist=$1
prefix=$2
build=$3
Ddir=$4
pdir=$chdir/$pdir

if test "$wigformat" = "0"; then
    postfix="wig.gz"
elif test "$wigformat" = "1"; then
    postfix="wig"
elif test "$wigformat" = "2"; then
    postfix="bedGraph"
elif test "$wigformat" = "3"; then
    postfix="bw"
else
    echo "Error: specify [0-3] for '-f' option."
fi

if test ! -e $samplepairlist; then
    echo "Error: $samplepairlist does not exist."
    exit 1
fi

if test "$post_predefined" = ""; then
    if test $mp -eq 1; then
        post=-bowtie2-$build-raw-mpbl-GR
    else
        post=-bowtie2-$build-raw-GR
    fi
else
    post=$post_predefined
fi

if test $showpvalue -eq 1; then
    param="$param --showctag 0 --showpenrich 1"
fi

ex(){ echo $1; eval $1; }

gt=$Ddir/genometable.txt
if test ! -e $gt; then
    echo "Error: $gt does not exist. Please make it by 'download_genomedata.sh'."
    exit 1
fi

pdfdir=$chdir/pdf
mkdir -p $pdfdir

if test $yeast -eq 1; then
    # yeast mode
    dir=parse2wigdir+
    gene=../data/S_cerevisiae/SGD_features.tab
    gt=../data/genometable/genometable.sacCer3.txt
    drompa+ PC_ENRICH \
            -i $dir/YST1019_Gal_60min.100.bw,$dir/YST1019_Gal_0min.100.bw,YST1019_Gal,,,200 \
        -i $dir/YST1019_Raf_60min.100.bw,$dir/YST1019_Raf_0min.100.bw,YST1019_Raf,,,200 \
        -i $dir/YST1053_Gal_60min.100.bw,$dir/YST1053_Gal_0min.100.bw,YST1053_Gal,,,200 \
        -o drompa-yeast --gt $gt -g $gene --gftype 2 \
        --scale_ratio 1 --ls 200 --sm 10 --lpp 3
    s=""
#    while IFS=, read chip input label mode peak; do
    while read LINE; do
        LINE=(${LINE//,/ })
        chip=${LINE[0]}
        input=${LINE[1]}
        label=${LINE[2]}

        if test "$input" != ""; then
            s="$s -i $pdir/$chip$post.100.$postfix,$pdir/$input$post.100.$postfix,$label"
        else
            echo "sample $chip does not have the input sample. skipped.."
        fi
    done < $samplepairlist

    head=`basename $prefix`

    echo -en "Command: "
    echo "drompa+ PC_ENRICH $s -o drompa-yeast --gt $gt -g $gene --gftype 2 --scale_ratio 1 --ls 200 --sm 10 --lpp 3"
V $param $sGV -o $pdfdir/$head.GV.100000 --gt $gt --ideogram $ideogram --GC $GC --gcsize 500000 --GD $GD --gdsize 50000 >& $pdfdir/$head.GV.100000.log" > $pdfdir/$head.GV.100000.log
    ex "drompa+ GV $param $sGV -o $pdfdir/$head.GV.100000 --gt $gt --ideogram $ideogram --GC $GC --gcsize 500000 --GD $GD --gdsize 500000 | tee -a $pdfdir/$head.GV.100000.log"
elif test $GV -eq 1; then
    # GV mode
    ideogram=/opt/DROMPAplus/data/ideogram/$build.tsv
    GC=$Ddir/GCcontents/
    GD=$Ddir/gtf_chrUCSC/genedensity

    sGV=""
#    while IFS=, read chip input label mode peak; do
    while read LINE; do
        LINE=(${LINE//,/ })
        chip=${LINE[0]}
        input=${LINE[1]}
        label=${LINE[2]}

        if test "$input" != ""; then
            sGV="$sGV -i $pdir/$chip$post.100000.$postfix,$pdir/$input$post.100000.$postfix,$label"
        else
            echo "sample $chip does not have the input sample. skipped.."
        fi
    done < $samplepairlist

    head=`basename $prefix`

    echo -en "Command: "
    echo "drompa+ GV $param $sGV -o $pdfdir/$head.GV.100000 --gt $gt --ideogram $ideogram --GC $GC --gcsize 500000 --GD $GD --gdsize 50000 >& $pdfdir/$head.GV.100000.log" > $pdfdir/$head.GV.100000.log
    ex "drompa+ GV $param $sGV -o $pdfdir/$head.GV.100000 --gt $gt --ideogram $ideogram --GC $GC --gcsize 500000 --GD $GD --gdsize 500000 | tee -a $pdfdir/$head.GV.100000.log"
else
    s=""
#    while IFS=, read chip input label mode peak; do
    while read LINE; do
        LINE=(${LINE//,/ })
        chip=${LINE[0]}
        input=${LINE[1]}
        label=${LINE[2]}
        peak=${LINE[4]}

        if test "$peak" != ""; then
            peak=$chdir/$peak
        fi

        if test "$input" != ""; then
            s="$s -i $pdir/$chip$post.$binsize.$postfix,$pdir/$input$post.$binsize.$postfix,$label,$peak"
        else
            s="$s -i $pdir/$chip$post.$binsize.$postfix,,$label,$peak"
        fi
    done < $samplepairlist

    gene=$Ddir/gtf_chrUCSC/chr.gene.refFlat
    head=`basename $prefix`

    echo -en "Command: "
    echo "drompa+ PC_SHARP $param $s -o $pdfdir/$head.PCSHARP.$binsize --gt $gt -g $gene --ls $linesize --showchr --callpeak >& $pdfdir/$head.PCSHARP.$binsize.log" > $pdfdir/$head.PCSHARP.$binsize.log
    ex "drompa+ PC_SHARP $param $s -o $pdfdir/$head.PCSHARP.$binsize --gt $gt -g $gene --ls $linesize --showchr --callpeak | tee -a $pdfdir/$head.PCSHARP.$binsize.log"
    rm $pdfdir/$head.PCSHARP.$binsize.pdf
fi
