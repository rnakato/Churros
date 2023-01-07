#!/bin/bash
cmdname=`basename $0`
function usage()
{
    echo "$cmdname [Options] <index> <fastq>" 1>&2
    echo '   <index>: Bismark index directory' 1>&2
    echo '   <fastq>: Input fastq file' 1>&2
    echo '   Options:' 1>&2
    echo '      -d <str>: output directory (defalt: "Bismarkdir")' 1>&2
    echo '      -m <mode>: Bismark mode ([directional|non_directional|pbat|rrbs], default: directional)' 1>&2
    echo '      -p : number of CPUs (default: 4)' 1>&2
}

odir=Bismarkdir
ncore=4
mode=directional

while getopts d:m:p: option
do
    case ${option} in
        d) odir=${OPTARG};;
        m) mode=${OPTARG};;
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

if test $# -ne 2; then
    usage
    exit 0
fi

index=$1
fastq=$2

ex(){ echo $1; eval $1; }

fqdir=$odir/trimmed_fastq
mkdir -p $fqdir
if test $mode = "directional"; then
    bismarkparam=""
elif test $mode = "non_directional"; then
    bismarkparam="--non_directional"
elif test $mode = "pbat"; then
    bismarkparam="--pbat"
elif test $mode = "rrbs"; then
    ex "trim_galore --cores $ncore --rrbs $fastq -o $odir/trimmed_fastq"
    fastq=`ls $fqdir/*.gz`
    bismarkextractparam="--ignore_r2 2"
elif test $mode = "bs_seq"; then
    bismarkextractparam="--ignore_r2 2"
else
    echo "error: specify [directional|non_directional|pbat|rrbs] for -m:"
    echo "specified: $mode"
    exit
fi

ex "bismark --genome $index -o $odir --temp_dir $odir/tmp -p $ncore $bismarkparam $fastq"
rm -rf $odir/tmp

outputbam=`ls $odir/*_bismark_bt2*.bam | grep -v deduplicated`
if test $mode = "rrbs"; then
    echo "Because this is RRBS mode, the deduplication step is skipped."
else
    ex "deduplicate_bismark --bam $outputbam --output_dir $odir"
    outputbam=`ls $odir/*_bismark_bt2*.deduplicated.bam`
fi
ex "bismark_methylation_extractor $bismarkextractparam --gzip --bedGraph $outputbam -o $odir"
ex "bam2nuc --dir $odir --genome_folder $index $outputbam"

cd $odir
ex "bismark2report"
ex "bismark2summary"
ex "multiqc --pdf --force ."
cd ..
