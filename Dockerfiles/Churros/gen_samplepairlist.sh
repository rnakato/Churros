#!/bin/bash

cmdname=`basename $0`
function usage()
{
    echo "$cmdname samplelist.txt > samplepairlist.txt" 1>&2
    echo '   Options:' 1>&2
    echo '      -b: Output "broad" for peak mode' 1>&2
    echo '      -n: Output "none" for input samples' 1>&2
}

broad=0
none=0
while getopts bn option
do
    case ${option} in
        b) broad=1 ;;
        n) none=1 ;;
	*)
	    usage
	    exit 1
	    ;;
    esac
done
shift $((OPTIND - 1))

if test $# -ne 1; then
    usage
    exit 0
fi

file=$1

if test $broad = "1"; then
    mode="broad"
else
    mode="sharp"
fi
if test $none = "1"; then
    input="none"
else
    input=""
fi

awk -F '\t' -v input="$input" -v mode="$mode" '{print $1","input","$1","mode""}' $file
