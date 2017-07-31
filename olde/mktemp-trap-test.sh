#!/bin/bash

#testing commands

cleanup(){
#	rm $file0
#	rm $file1
	rm -r $dir0
}

dir0=$(mktemp -d `basename $0`.XXX)
file0=$(mktemp $dir0/XXXXX.txt)
file1=$(mktemp $dir0/`basename $0`.XXXXX.txt)

echo "this is a temp file named $file0." > $file0
echo "this is a temp file called $file1." > $file1

echo "this file is named: "$file0
echo "this file is named: "$file1

cat $file0
cat $file1

ls -ahl
ls -ahl $dir0/

trap cleanup EXIT
