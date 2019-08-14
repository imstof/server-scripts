#!/bin/bash

#make sure an ipmi is online
#one arg = nodeset

for node in $(nodeset -e $1)
do
	[[ -z $(ping -c1 $node | grep ' 0% packet loss') ]] && mail -s "$node not pinging" cehnstrom@techsquare.com
done
