#!/bin/bash
cmdname=`basename $0`
function usage()
{
    echo "$cmdname [options] <mapfile> <prefix> <build> <Ddir>" 1>&2
    echo '   <mapfile>: mapfile (SAM|BAM|CRAM|TAGALIGN format)' 1>&2
    echo '   <prefix>: output prefix' 1>&2
    echo '   <build>: genome build (e.g., hg38)' 1>&2
    echo '   <Ddir>: directory of bowtie2 index' 1>&2
    echo '   Options:' 1>&2
    echo '      -a: also outout raw read distribution' 1>&2
    echo '      -b: binsize of parse2wig+ (defalt: 100)' 1>&2
    echo '      -z: peak file for FRiP calculation (BED format)' 1>&2
    echo '      -m: consider genome mappability' 1>&2
    echo '      -k: read length (36 or 50) for mappability calculation (default: 50)' 1>&2
    echo '      -p: for paired-end file' 1>&2
    echo '      -t: number of CPUs (default: 4)' 1>&2
    echo '      -o: output directory (default: parse2wigdir+)' 1>&2
    echo '      -f: output format of parse2wig+ (default: 3)' 1>&2
    echo '               0: compressed wig (.wig.gz)' 1>&2
    echo '               1: uncompressed wig (.wig)' 1>&2
    echo '               2: bedGraph (.bedGraph)' 1>&2
    echo '               3: bigWig (.bw)' 1>&2
    echo '      -D outputdir: output dir (defalt: ./)' 1>&2
    echo "   Example:" 1>&2
    echo "      For single-end: $cmdname chip.sort.bam chip hg38 Database/Ensembl-GRCh38" 1>&2
    echo "      For paired-end: $cmdname -p chip.sort.bam chip hg38 Database/Ensembl-GRCh38" 1>&2
}

binsize=100
k=50
pdir=parse2wigdir+
all=0
of=3
pair=""
mp=0
peak=""
ncore=4
chdir="./"

while getopts ab:z:mk:o:f:pt:D: option
do
    case ${option} in
	a) all=1;;
	b) binsize=${OPTARG};;
	z) peak=${OPTARG}
	   if test ! -e $peak; then
	       echo "Error: $peak does not exist (-b)."
	       exit 1
	   else
	       peak="--bed $peak"
	   fi
	   ;;
	m) mp=1;;
	k) k=${OPTARG};;
	o) pdir=${OPTARG};;
	f) of=${OPTARG};;
	p) pair="--pair";;
	t) ncore=${OPTARG};;
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

bam=$1
prefix=$2
build=$3
Ddir=$4

pdir=$chdir/$pdir
logdir=$chdir/log
mkdir -p $logdir

ex(){ echo $1; eval $1; }

gt=$Ddir/genometable.txt
chrpath=$Ddir/chromosomes
#mptable=$Ddir/mappability_Mosaics_${k}mer/map_fragL150_genome.txt
mptable=/opt/SSP/data/mptable/mptable.UCSC.$build.${k}mer.flen150.txt
mpbinary=$Ddir/mappability_Mosaics_${k}mer

if test "$mp" -eq 1; then
    echo "consider mappability: $mptable"
    mppost="-mpbl"
    mpbin="--mpdir $mpbinary"
else
    mppost=""
    mpbin=""
fi
mpparam="--mptable $mptable"

parse2wigparam="--gt $gt -i $bam $mpparam $pair $peak --odir $pdir --outputformat $of -p $ncore"

func(){
    if test $all = 1; then
#	if test ! -e $pdir/$prefix-raw$mppost.$binsize.tsv; then
	    ex "parse2wig+ $parse2wigparam -o $prefix-raw$mppost --binsize $binsize"
#	fi
    fi

    if test $build = "scer" -o $build = "pombe"; then
	bins="$binsize"
    else
	bins="$binsize 5000 100000"
    fi
    for b in $bins; do
#	if test ! -e $pdir/$prefix-raw$mppost-GR.$b.tsv; then
	    ex "parse2wig+ $parse2wigparam -o $prefix-raw$mppost-GR -n GR --binsize $b"
#	fi
    done
    if test "$mp" -eq 1; then
#	if test ! -e $pdir/$prefix-GC-depthoff$mppost-GR.100000.tsv; then
	    ex "parse2wig+ $parse2wigparam -o $prefix-GC-depthoff$mppost-GR -n GR --chrdir $chrpath $mpbin --binsize 100000 --gcdepthoff"
#	fi
	parsestats4DROMPAplus.pl $pdir/$prefix-GC-depthoff$mppost-GR.100000.tsv >& $logdir/parsestats-$prefix.GC.100000
    fi
}

echo "Parsing $bam by parse2wig+."
func >& $logdir/parse2wig+-$prefix

parsestats4DROMPAplus.pl $pdir/$prefix-raw$mppost-GR.$binsize.tsv >& $logdir/parsestats-$prefix.$binsize

echo "parse2wig+.sh done."
