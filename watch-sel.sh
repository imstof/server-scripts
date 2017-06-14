#!/bin/bash

# scrpit to monitor sel log for recent or specific activity.
# WHERE TO RUN?? No ipmi on service002, no nodeset on console/eofe1|45|7

# help func
show_help(){
	echo
	echo "Usage: `basename $0` [option...]"
	echo "Monitor SEL log for recent or specific activity"
	echo
	echo "	-n HOSTNAME(S)"
	echo "		hostname(s) to be checked" 
	echo "	-e EVENT_STRING"
	echo "		specific string to monitor SEL for"
	echo "		if no string is specified, script will report any new 'Asserted' event"
	echo "	-t"
	echo "		display to terminal (no mail)"
	echo "	-h"
	echo "		display this help and exit"
	echo
}

# set flags
nomail=false
event="Asserted"
while getopts :htn:e: opt
do
	case $opt in
		t)
			nomail=true
			;;
		n)
			nodes=$OPTARG
			;;
		e)
			event=$OPTARG
			;;
		h)
			show_help
			exit 0
			;;
		\?)
			echo "Invalid option: -$OPTARG"
			echo "Try '`basename $0` -h' for help"
			exit 1
			;;
		:)
			echo "Option -$OPTARG requires an argument"
			echo "Try '`basename $0` -h' for help"
			exit 1
			;;
	esac
done

if [[ -z $nodes ]]
then
	echo "Option -h must be specified"
	echo "Try '`basename $0` -h' for help"
	exit 1
else
	nodelist=$(nodeset -e $nodes)
fi


for node in $nodelist
do
	file0=/tmp/sel-$node-$(date +"%Y-%m-%d").txt
	file1=/tmp/sel-$node-$(date --date="yesterday" +"%Y-%m-%d").txt
# create day-olde file if it does not exist (for 1st day)
	if [[ ! -e $file1 ]]
	then
		ipmitool -I lanplus -H $node.ipmi.cluster -U root -P calvin sel list >> $file1
	fi

	echo "$node-$(date +"%Y-%m-%d")" >> $file0
	ipmitool -I lanplus -H $node.ipmi.cluster -U root -P calvin sel list >> $file0

	if [[ -n $(diff $file0 $file1 | grep $event) ]] 
	then
		if [[ $nomail == false ]]
		then
			mail -s "$node SEL event $(date +"%Y-%m-%d % %T")" cehnstrom@techsquare.com < $file0
		else 
			echo "$node SEL event $(date +"%Y-%m-%d %T")"
			echo "========================================="
			cat $file0
		fi
	fi
	rm /tmp/sel-$node-$(date --date="2 days ago" +"%Y-%m-%d").txt
done

