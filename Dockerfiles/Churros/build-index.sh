#!/bin/bash
cmdname=`basename $0`
pwd=`pwd`
function usage()
{
    echo "$cmdname [-p ncore] -a <program> <odir>" 1>&2
    echo "   <program>: bowtie, bowtie-cs, bowtie2, bwa, chromap" 1>&2
    echo '   <Ddir>: Reference data directory' 1>&2
    echo "   Example:" 1>&2
    echo "         $cmdname bowtie2 Referencedata_hg38" 1>&2
}

ncore=4
full=0
while getopts ap: option
do
    case ${option} in
        a) full=1;;
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

if [ $# -ne 2 ]; then
  usage
  exit 1
fi

ex(){
    program=$1
    name=$2
    command=$3
    command_version=$4
    mkdir -p $odir/log
    log="$odir/log/build-index.$program.$name.log"
    echo $program
    echo "Version:" > $log
    $command_version >> $log 2>&1
    echo "" >> $log
    echo "Command:" >> $log
    echo $command >> $log
    echo "" >> $log
    echo "Log:" >> $log
    eval $command >> $log 2>&1
}

program=$1
odir=$2

if test $full = 1 ; then
    fa="$odir/genome_full.fa"
    name=genome_full
else
    fa="$odir/genome.fa"
    name=genome
fi

if test $program = "chromap" ; then
    binary="chromap"
    indexdir=$odir/chromap-indexes
    mkdir -p $indexdir
    command="$binary -i -t $ncore -r $fa -o $indexdir/$name"
    command_version="$binary --version"
    ex $program $name "$command" "$command_version"
elif test $program = "bowtie" ; then
    binary=bowtie-build
    indexdir=$odir/bowtie-indexes
    mkdir -p $indexdir
    command="$binary $fa $indexdir/$name"
    command_version="$binary --version"
    ex $program $name "$command" "$command_version"
elif test $program = "bowtie-cs" ; then
    binary=/opt/bowtie-1.1.2/bowtie-build
    indexdir=$odir/bowtie-indexes
    mkdir -p $indexdir
    command="$binary -C $fa $indexdir/$name-cs"
    command_version="$binary --version"
    ex $program-cs $name "$command" "$command_version"
elif test $program = "bowtie2" ; then
    binary="bowtie2-build"
    indexdir=$odir/bowtie2-indexes
    mkdir -p $indexdir
    command="$binary --threads $ncore $fa $indexdir/$name"
    command_version="$binary --version"
    ex $program $name "$command" "$command_version"
    ln -rsf $fa $indexdir/$name.fa
elif test $program = "bwa" ; then
    binary="bwa"
    indexdir=$odir/bwa-indexes
    mkdir -p $indexdir
    command="$binary index -p $indexdir/$name $fa"
    command_version="$binary"
    ex $program $name "$command" "$command_version"
    ln -rsf $fa $indexdir/$name
fi
