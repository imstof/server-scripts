#!/bin/bash

#two args = nodeset, status|off|on|cycle

for node in $(nodeset -e $1)
do
	ipmitool -Ilanplus -Uroot -Pcalvin -H $node.ipmi.cluster power $2
done
