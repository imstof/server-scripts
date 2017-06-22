#!/bin/bash

#testing commands

cleanup(){
	rm $file0
	rm $file1
}

file0=$(mktemp `basename $0`.XXXXX.txt)
file1=$(mktemp `basename $0`.XXXXX)

echo "this file is named: "$file0
echo "this file is named: "$file1

cat $file0
cat $file1

ls

trap cleanup EXIT
