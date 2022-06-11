#!/bin/bash
cmdname=`basename $0`
function usage()
{
    echo "$cmdname [Options] <Ddir>" 1>&2
    echo '   <Ddir>: directory of the genome' 1>&2
    echo '   Options:' 1>&2
    echo '      -f <int>: fragment length (default: 150)' 1>&2
    echo '      -b <array <int>>: binsizes (default: "10000 25000 50000 500000 1000000")' 1>&2
    echo '      -r <array <int>>: read length (default: "36 50")' 1>&2
    echo '      -p <int>: number of CPUs (default: 12)' 1>&2
    echo "   Example:" 1>&2
    echo "      $cmdname Ensembl-GRCh38" 1>&2
}

ncore=12
fraglen=150
arr_readlen="36 50"
arr_binsize="10000 25000 50000 500000 1000000"
while getopts f:r:b:p: option
do
    case ${option} in
        f) fraglen=${OPTARG};;
        r) arr_readlen=${OPTARG};;
        b) arr_binsize=${OPTARG};;
	p) ncore=${OPTARG};;
        *)
            usage
            exit 1
            ;;
    esac
done
shift $((OPTIND - 1))

if [ $# -ne 1 ]; then
  usage
  exit 1
fi

Ddir=$1
Mdir=/opt/scripts/MOSAiCS_mappability/

ex(){ echo $1; eval $1; }

read_genometable(){
    gt=$1
    local i=0
    while read line; do
	CHR[$i]=`echo $line | awk '{printf $1}'`
	LEN[$i]=`echo $line | awk '{printf $2}'`
	i=`expr $i + 1`
    done < $gt
}


func_hashing_eachchr(){
    dir=$1
    chr=$2

    if test -e $dir/$chr.fa; then
	if test ! -e $dir/$chr.fa.HashOffsetTable || test ! -s $dir/$chr.fa.HashOffsetTable; then
	    ex "$Mdir/chr2hash $dir/$chr.fa"
        fi
    else
        echo "warning: $dir/$chr.fa does not exist."
    fi
}

func_hashing(){
    gt=$1
    dir=$2

    unset CHR
    unset LEN
    read_genometable $gt

    echo "${CHR[@]}" | xargs -n1 -P $ncore ash -c "func_hashing_eachchr $dir {}"
#    for ((i=0; i<${#CHR[@]}; i++)); do
#	func_hashing_eachchr $dir ${CHR[$i]}
 #   done
}

oligoFind(){
    gt=$1
    readlen=$2
    dir=$3
    hashdir=$4

    unset CHR
    unset LEN
    read_genometable $gt

    func(){
	local i=$1
	for ((j=0; j<${#CHR[@]}; j++)); do
	    outfile=$hashdir/${CHR[$i]}x${CHR[$j]}.${readlen}mer.out
	    if test ! -e $outfile || test ! -s $outfile; then
		ex "$Mdir/oligoFindPLFFile $dir/${CHR[$i]}.fa $dir/${CHR[$j]}.fa $readlen 0 0 1 1 > $outfile"
	    fi
	done
    }

    for ((i=0; i<${#CHR[@]}; i++)); do func $i; done
}

mergeOligo(){
    gt=$1
    readlen=$2
    hashdir=$3
    odir=$Ddir/mappability_${readlen}mer
    if test ! -e $odir; then mkdir $odir; fi

    unset CHR
    unset LEN
    read_genometable $gt

    for ((i=0; i<${#CHR[@]}; i++)); do
	outfile=$odir/${CHR[$i]}b.out
	if test ! -e $outfile || test ! -s $outfile; then
	    ex "$Mdir/mergeOligoCounts $hashdir/chr*${CHR[$i]}.${readlen}mer.out > $outfile"
	fi
    done
}

MOSAICS(){
    gt=$1
    readlen=$2
    fraglen=$3
    binsize=$4
    dir=$5
    hashdir=$6

    unset CHR
    unset LEN
    read_genometable $gt

    scriptsdir=/opt/scripts/MOSAiCS_scripts
    Mosdir=$Ddir/mappability_Mosaics_${readlen}mer
    ex "mkdir -p $Mosdir"

    eachchr(){
	local chr=$1
	echo $chr
	outfile=$Mosdir/map_${chr}_binary.txt
	echo $outfile
	if test ! -e $outfile || test ! -s $outfile; then
	    ex "/usr/bin/python $scriptsdir/cal_binary_map_score.py $Mosdir/${chr}b.out 1 ${LEN[$i]} > $outfile"
	fi
	ex "perl $scriptsdir/process_score_java.pl $outfile $Mosdir/map_fragL${fraglen}_${chr}_bin${binsize}.txt $readlen $fraglen $binsize"
	ex "perl $scriptsdir/cal_binary_GC_N_score.pl $dir/${chr}.fa $Mosdir/${chr} 1"

	for str in GC N; do
	    ex "perl $scriptsdir/process_score.pl \
		 $Mosdir/${chr}_${str}_binary.txt \
		 $Mosdir/${str}_fragL${fraglen}_${chr}_bin${binsize}.txt \
		 $fraglen $binsize"
	done
    }
    for ((i=0; i<${#CHR[@]}; i++)); do eachchr ${CHR[$i]}; done

    ex "makemappabilitytable.pl $gt $Mosdir/map > $Mosdir/map_fragL${fraglen}_genome.txt"
}

hashdir=$Ddir/mappability_hashtable
chrdir=$Ddir/chromosomes
gt=$Ddir/genometable.txt

if test ! -e $hashdir; then mkdir $hashdir; fi
func_hashing $gt $chrdir

for readlen in $arr_readlen
do
    oligoFind $gt $readlen $chrdir $hashdir
    mergeOligo $gt $readlen $hashdir

    for binsize in $arr_binsize
    do
	MOSAICS $gt $readlen $fraglen $binsize $chrdir $hashdir
    done
done
