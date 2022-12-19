#!/bin/bash

tmpfile=$(mktemp)

if nkf --help >& /dev/null; then
    nkf -Lu $1 > $tmpfile
    mv $tmpfile $1
else
    echo "Error: nkf not found."
fi
