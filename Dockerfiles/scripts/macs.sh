#!/bin/bash
function usage()
{
    echo "macs.sh [-s species] [-f fraglen] [-q qvalue] [-d outputdir] <IP bam> <Input bam> <prefix> [sharp|broad|nomodel|broad-nomodel]" 1>&2
}

flen=100
qval=0.05
species="hs"
mdir=macs
while getopts s:f:q:d: option
do
    case ${option} in
        s) species=${OPTARG};;
	f) flen=${OPTARG};;
	q) qval=${OPTARG};;
	d) mdir=${OPTARG};;
	*)
	    usage
	    exit 1
	    ;;
    esac
done
shift $((OPTIND - 1))

if test $# -ne 4; then
    usage
    exit 0
fi

if test ! -e $mdir; then mkdir $mdir; fi

IP=$1
Input=$2
peak=$3
mode=$4

ex(){ echo $1; eval $1; }

if test -e $IP && test -s $IP ; then
    n=1 # dummy
else
    echo "$IP does not exist."
fi

if test $Input = "none"; then
    macs="macs2 callpeak -t $IP -g $species -f BAM"
else
    macs="macs2 callpeak -t $IP -c $Input -g $species -f BAM"
    if test -e $Input && test -s $Input; then
        n=1 # dummy
    else
        echo "$Input does not exist."
    fi
fi

if   test $mode = "sharp";         then ex "$macs -q $qval -n $mdir/$peak"
elif test $mode = "nomodel";       then ex "$macs -q $qval -n $mdir/$peak --nomodel --shift $flen"
elif test $mode = "broad";         then ex "$macs -q $qval -n $mdir/$peak --broad"
elif test $mode = "broad-nomodel"; then ex "$macs -q $qval -n $mdir/$peak --nomodel --shift $flen --broad"
else
    echo "Error: specify [sharp|broad|nomodel|broad-nomodel] for mode."
    exit 1
fi
