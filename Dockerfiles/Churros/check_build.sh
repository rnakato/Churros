#!/bin/bash
build=$1

if test "$build" = "hg38" -o "$build" = "hg19" -o "$build" = "T2T"; then
    echo "Human genome build $build"
elif test "$build" = "mm39" -o "$build" = "mm10"; then
    echo "Mouse genome build $build"
elif test "$build" = "rn7"; then
    echo "Rat genome build $build"
elif test "$build" = "dm6"; then
    echo "Fly genome build $build"
elif test "$build" = "danRer11"; then
    echo "Zebrafish genome build $build"
elif test "$build" = "galGal6"; then
    echo "Chicken genome build $build"
elif test "$build" = "xenLae2"; then
    echo "Clawed frog genome build $build"
elif test "$build" = "ce11"; then
    echo "C. elegans genome build $build"
elif test "$build" = "sacCer3"; then
    echo "S. cerevisiae genome build $build"
elif test "$build" = "SPombe"; then
    echo "S. pombe genome build $build"
else
    echo "Error: invalid genome build: $build"
    exit 1
fi

exit 0
