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
    echo '      -l: predefined fragment length (default: estimated by trand-shift profile)' 1>&2
    echo '      -m: consider genome mappability' 1>&2
    echo '      -k: read length (36 or 50) for mappability calculation (default: 50)' 1>&2
    echo '      -p: for paired-end file' 1>&2
    echo '      -t: number of CPUs (default: 4)' 1>&2
    echo '      -o: output directory (default: parse2wigdir+)' 1>&2
    echo '      -s: stats directory (default: log/parse2wig+)' 1>&2
    echo '      -f: output format of parse2wig+ (default: 3)' 1>&2
    echo '               0: compressed wig (.wig.gz)' 1>&2
    echo '               1: uncompressed wig (.wig)' 1>&2
    echo '               2: bedGraph (.bedGraph)' 1>&2
    echo '               3: bigWig (.bw)' 1>&2
    echo '      -D outputdir: output dir (defalt: ./)' 1>&2
    echo '      -F: overwrite files if exist (defalt: skip)' 1>&2
    echo "   Example:" 1>&2
    echo "      For single-end: $cmdname chip.sort.bam chip hg38 Referencedata_hg38" 1>&2
    echo "      For paired-end: $cmdname -p chip.sort.bam chip hg38 Referencedata_hg38" 1>&2
}

binsize=100
k=50
pdir=parse2wigdir+
all=0
of=3
pair=""
mp=0
peak=""
param_flen=""
ncore=4
chdir="./"
statsdir="log/parse2wig+"
force=0

while getopts ab:z:l:mk:o:s:f:pt:D:F option
do
    case ${option} in
	a) all=1;;
	b) binsize=${OPTARG}
           isnumber.sh $binsize "-b" || exit 1
	   ;;
	z) peak=${OPTARG}
	   if test ! -e $peak; then
	       echo "Error: $peak does not exist (-b)."
	       exit 1
	   else
	       peak="--bed $peak"
	   fi
	   ;;
	l) param_flen="--nomodel --flen ${OPTARG}";;
	m) mp=1;;
	s) statsdir=${OPTARG};;
	k) k=${OPTARG}
           isnumber.sh $k "-k" || exit 1
	   ;;
	o) pdir=${OPTARG};;
	f) of=${OPTARG}
           isnumber.sh $of "-f" || exit 1
	   ;;
        p) pair="--pair";;
        t) ncore=${OPTARG}
           isnumber.sh $ncore "-p" || exit 1
           ;;
        D) chdir=${OPTARG};;
	F) force=1;;
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

check_build.sh $build || exit 1

pdir=$chdir/$pdir
logdir=$chdir/log/parse2wig+
statsdir=$chdir/$statsdir
mkdir -p $logdir $statsdir

ex(){ echo $1; eval $1; }

gt=$Ddir/genometable.txt
if test ! -e $gt; then
    echo "Error: $gt does not exist."
    exit 1
fi

chrpath=$Ddir/chromosomes
mptable=$Ddir/mappability_Mosaics_${k}mer/map_fragL150_genome.txt
#mptable=/opt/SSP/data/mptable/mptable.UCSC.$build.${k}mer.flen150.txt
mpbinary=$Ddir/mappability_Mosaics_${k}mer

if test "$mp" -eq 1; then
    echo "consider mappability: $mptable"
    mppost=".mpbl"
    mpbin="--mpdir $mpbinary"
else
    mppost=""
    mpbin=""
fi
mpparam="--mptable $mptable"

parse2wigparam="--gt $gt -i $bam $mpparam $pair $peak --outputformat $of -p $ncore $param_flen"

func(){
    if test $build = "scer" -o $build = "pombe" -o $build = "sacCer3" -o $build = "Spom"; then
        bins="$binsize"
    else
        bins="$binsize 5000 100000"
    fi

    if test $all = 1; then
        rdir=$pdir/RawCount
        mkdir -p $rdir
        for b in $bins; do
            file=$rdir/$prefix$mppost.$b.bw
            if test -e "$file" -a 1000 -lt `wc -c < $file` -a $force -eq 0 ; then
                echo "$file already exist. skipping"
            else
                ex "parse2wig+ --odir $rdir $parse2wigparam -o $prefix$mppost --binsize $b"
#                rm $rdir/$prefix$mppost.$b.tsv
            fi
        done
    fi

    tdir=$pdir/TotalReadNormalized
    mkdir -p $tdir
    for b in $bins; do
        file=$tdir/$prefix$mppost.$b.bw
        if test -e "$file" -a 1000 -lt `wc -c < $file` -a $force -eq 0 ; then
            echo "$file already exist. skipping"
        else
            ex "parse2wig+ --odir $tdir $parse2wigparam -o $prefix$mppost -n GR --binsize $b"
#            cp $tdir/$prefix$mppost.$b.tsv $statsdir/$prefix.stats.tsv
            parsestats4DROMPAplus.pl $tdir/$prefix$mppost.$b.tsv >& $statsdir/$prefix.stats.singleline.tsv
        fi
    done
    if test "$mp" -eq 1; then
        file=$tdir/$prefix$mppost.GCnormed.100000.bw
        if test -e "$file" -a 1000 -lt `wc -c < $file` -a $force -eq 0 ; then
            echo "$file already exist. skipping"
        else
            ex "parse2wig+ --odir $tdir $parse2wigparam -o $prefix$mppost.GCnormed -n GR --chrdir $chrpath $mpbin --binsize 100000 --gcdepthoff"
        fi
#        mv $tdir/$prefix$mppost.GCnormed.100000.tsv $statsdir/$prefix.stats.GC.tsv
        parsestats4DROMPAplus.pl $tdir/$prefix$mppost.GCnormed.100000.tsv >& $statsdir/$prefix.stats.singleline.GC.tsv
        mv $tdir/$prefix$mppost.GCnormed.GCdist.tsv $statsdir/$prefix.GCdistribution.tsv

        # remove normal stats files if GC stats are available
        rm $statsdir/$prefix.stats.singleline.tsv
    fi
}

echo "Parsing $bam by parse2wig+."
func >& $logdir/$prefix.txt

#echo "parse2wig+.sh done."
