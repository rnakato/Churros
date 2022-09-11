#!/bin/bash
0;136;0ccmdname=`basename $0`
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
        f) fraglen=${OPTARG}
           isnumber.sh $fraglen "-f" || exit 1
           ;;
        r) arr_readlen=${OPTARG};;
        b) arr_binsize=${OPTARG};;
        p) ncore=${OPTARG}
           isnumber.sh $ncore "-p" || exit 1
           ;;
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
export -f ex

read_genometable(){
    gt=$1
    local i=0
    while read line; do
	CHR[$i]=`echo $line | awk '{printf $1}'`
	LEN[$i]=`echo $line | awk '{printf $2}'`
	i=`expr $i + 1`
    done < $gt
}
export -f read_genometable

func_hashing_eachchr(){
    dir=$1
    chr=$2
    Mdir=/opt/scripts/MOSAiCS_mappability/

    if test -e $dir/$chr.fa; then
	if test ! -e $dir/$chr.fa.HashOffsetTable || test ! -s $dir/$chr.fa.HashOffsetTable; then
	    ex "$Mdir/chr2hash $dir/$chr.fa"
        fi
    else
        echo "warning: $dir/$chr.fa does not exist."
    fi
}
export -f func_hashing_eachchr

func_hashing(){
    gt=$1
    dir=$2
    hashdir=$3

    unset CHR
    unset LEN
    read_genometable $gt

    echo ${CHR[@]} | tr ' ' '\n' | xargs -n1 -I {} -P $ncore bash -c "func_hashing_eachchr $dir {} $hashdir"
}

oligoFind(){
    gt=$1
    readlen=$2
    dir=$3
    hashdir=$4

    unset CHR
    unset LEN
    read_genometable $gt

    func_oligoFind(){
	chr1=$1
	dir=$2
	hashdir=$3
	readlen=$4
	gt=$5
	Mdir=/opt/scripts/MOSAiCS_mappability/

	read_genometable $gt

	for chr2 in ${CHR[@]}; do
	    outfile=$hashdir/${chr1}x${chr2}.${readlen}mer.out
	    if test ! -e $outfile || test ! -s $outfile; then
		ex "$Mdir/oligoFindPLFFile $dir/$chr1.fa $dir/$chr2.fa $readlen 0 0 1 1 > $outfile"
	    fi
	done
    }
    export -f func_oligoFind

    echo ${CHR[@]} | tr ' ' '\n' | xargs -n1 -I {} -P $ncore bash -c "func_oligoFind {} $dir $hashdir $readlen $gt"
}

mergeOligo(){
    gt=$1
    readlen=$2
    hashdir=$3
    odir=$Ddir/mappability_hashdir_${readlen}mer
    if test ! -e $odir; then mkdir $odir; fi

    unset CHR
    unset LEN
    read_genometable $gt

    func_mergeOligo(){
	chr=$1
	readlen=$2
	odir=$3
	hashdir=$4
	outfile=$odir/${chr}b.out
	Mdir=/opt/scripts/MOSAiCS_mappability/

	if test ! -e $outfile || test ! -s $outfile; then
	    ex "$Mdir/mergeOligoCounts $hashdir/chr*$chr.${readlen}mer.out > $outfile"
	fi
    }
    export -f func_mergeOligo

    echo ${CHR[@]} | tr ' ' '\n' | xargs -n1 -I {} -P $ncore bash -c "func_mergeOligo {} $readlen $odir $hashdir"
}

func_MOSAICS(){
    gt=$1
    readlen=$2
    fraglen=$3
#    binsize=$4
    chrdir=$4

    unset CHR
    unset LEN
    read_genometable $gt

    Mosdir=$Ddir/mappability_Mosaics_${readlen}mer
    ex "mkdir -p $Mosdir"

    MOSAICS_eachchr(){
       i=$1
       Mosdir=$2
       readlen=$3
       fraglen=$4
       chrdir=$5
       Ddir=$6
       gt=$7
       arr_binsize=$8
       scriptsdir=/opt/scripts/MOSAiCS_scripts

       read_genometable $gt
       chr=${CHR[$i]}
       len=${LEN[$i]}

       outfile=$Mosdir/map_${chr}_binary.txt
       echo $chr $outfile
       ex "/usr/bin/python $scriptsdir/cal_binary_map_score.py $Ddir/mappability_hashdir_${readlen}mer/${chr}b.out 1 $len > $outfile"
       ex "perl $scriptsdir/cal_binary_GC_N_score.pl $chrdir/${chr}.fa $Mosdir/${chr} 1"

       for binsize in $arr_binsize; do
	   ex "perl $scriptsdir/process_score_java.pl $outfile $Mosdir/map_fragL${fraglen}_${chr}_bin${binsize}.txt $readlen $fraglen $binsize"
	   for str in GC N; do
               ex "perl $scriptsdir/process_score.pl $Mosdir/${chr}_${str}_binary.txt $Mosdir/${str}_fragL${fraglen}_${chr}_bin${binsize}.txt $fraglen $binsize" &
	   done
	   wait
       done
    }
    export -f MOSAICS_eachchr

    seq 0 $(( ${#CHR[@]} -1 )) | tr ' ' '\n' | xargs -n1 -I {} -P $ncore bash -c "MOSAICS_eachchr {} $Mosdir $readlen $fraglen $chrdir $Ddir $gt \"$arr_binsize\""
#    for ((i=0; i<${#CHR[@]}; i++)); do eachchr $i; done

    pigz -f $Mosdir/map_*_binary.txt
    ex "makemappabilitytable.pl $gt $Mosdir/map > $Mosdir/map_fragL${fraglen}_genome.txt"
}

hashdir=$Ddir/mappability_hashtable
chrdir=$Ddir/chromosomes
gt=$Ddir/genometable.txt

if test ! -e $hashdir; then mkdir $hashdir; fi
func_hashing $gt $chrdir $hashdir

for readlen in $arr_readlen
do
    oligoFind $gt $readlen $chrdir $hashdir
    mergeOligo $gt $readlen $hashdir

#    for binsize in $arr_binsize
 #   do
    func_MOSAICS $gt $readlen $fraglen $chrdir
    #done
done
