#!/bin/bash

file0=$(mktemp `basename $0`.XXX)
file1=$(mktemp `basename $0`.XXX)

/cm/shared/admin/bin/slurm-daily-node-status -t | grep .log > $file0

nodes=$(awk '{print $6}' $file0 | sort)

for node in $nodes
do
	echo $node | tee -a $file1
	timestamp=$(grep $node $file0 | awk '{print $4}' | cut -d':' -f1)
	ssh $node "grep $timestamp /var/log/slurmd" | tee -a $file1
	echo | tee -a $file1
done

echo "results at $(pwd)/$file1 (please delete when finished)"
trap 'rm $file0' EXIT
