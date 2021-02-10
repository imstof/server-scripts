#!/bin/bash

#default ipmi creds with ipmitool
#taks 2 args. nodename && "ipmi command"

for node in $(echo $1.ipmi.cluster | nodeset -e)
do
	ipmitool -Ilanplus -Uroot -Pcalvin -H $node $2
done

