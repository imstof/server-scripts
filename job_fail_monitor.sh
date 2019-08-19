#!/bin/bash

nodes=$(nodeset -e $1)

for node in $nodes
do
	file0=/home/imstof/job_fail_watch/$node-$(date +%Y%m%d)
	file1=/home/imstof/job_fail_watch/$node-$(date -d yesterday +%Y%m%d)
	sacct -N $node -S $(date -d "last week" +%Y-%m-%d) -s NF > $file0
	[[ -z $(cat $file1) ]] && break
	[[ -n $(diff $file0 $file1) ]] && mail -s "$node job fail" cehnstrom@techsquare.com
done
