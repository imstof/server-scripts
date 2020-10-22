#!/bin/bash

# run test and prompt for scontrol resume

for node in $(nodeset -e $1)
do
	echo $node
	ssh $node /cm/shared/admin/bin/test-node
	read -t 10 -p "resume node?" yn
	if [ -z "$yn" ]
	then
		continue
	fi
	if [ $yn == "y" ]
	then
		scontrol update state=resume node=$node
	fi
	echo "====================="
done
