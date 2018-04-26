#!/bin/bash

times=$(clush -wnode[236-308] '{ time echo 2^2^20 | bc -l > /dev/null ; } 2>&1' | grep real | sed 's/real//' | sed 's/\t//g' | sed 's/ //g')

for node in $times
do
	if [[ $(echo $(echo $node | awk -F'[ms]' '{print $2}')">10" | bc -l) -eq 1 ]]
	then nodes=$(echo $nodes $(echo $node | cut -d':' -f1))
	fi
done

echo $nodes | nodeset -f
