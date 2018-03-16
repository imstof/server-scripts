#!/bin/bash

# scrpit to monitor sel log for recent or specific activity.

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

report_file=/home/imstof/sel-cluster/REPORT-$(date +'%Y-%m-%d').txt
err_file=/home/imstof/sel-cluster/ERRORS-$(date +'%Y-%m-%d').txt
node_err=/home/imstof/sel-cluster/node_err.txt

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
	echo "Option -n must be specified"
	echo "Try '`basename $0` -h' for help"
	exit 1
else
	nodelist=$(nodeset -e $nodes)
fi

echo "DAILY SEL EVENT REPORT FOR "$(date +'%Y-%m-%d') > $report_file
echo "=====================================" >> $report_file
echo >> $report_file

echo "IPMI ERRORS FOR "$(date +'%Y-%m-%d') > $err_file
echo "==========================" >> $err_file
echo >> $err_file

for node in $nodelist
do
	file0=/home/imstof/sel-cluster/sel-$node-$(date +'%Y-%m-%d').txt
	file1=/home/imstof/sel-cluster/sel-$node-$(date --date="yesterday" +'%Y-%m-%d').txt
# create day-olde file if it does not exist (for 1st day)
	if [[ ! -e $file1 ]]
	then
		ipmitool -I lanplus -H $node.ipmi.cluster -U root -P calvin sel elist > $file1
	fi

	echo "$node-$(date +'%Y-%m-%d')" > $file0
	ipmitool -I lanplus -H $node.ipmi.cluster -U root -P calvin sel elist 2>$node_err > $file0

	if [[ -n $(cat $node_err) ]]
	then
		echo $node >> $err_file
		cat $node_err >> $err_file
	fi

	if [[ -n $(diff $file0 $file1 | grep $event) ]] 
	then
		if [[ $nomail == false ]]
		then
			echo "$node SEL event $(date +'%Y-%m-%d')" >> $report_file
			echo "===========================" >> $report_file
			tail $file1 >> $report_file
			echo >> $report_file
		else 
			echo "$node SEL event $(date +'%Y-%m-%d')"
			echo "==========================="
			diff $file0 $file1 | grep $event
			echo
		fi
	fi
	rm /home/imstof/sel-cluster/sel-$node-$(date --date="2 days ago" +'%Y-%m-%d').txt 2>/dev/null
done

if [[ -z $(sed '1,3d' $report_file) ]]
then
	echo "No SEL events to report" >> $report_file
fi

mail -s "SEL EVENT REPORT - $(date +'%Y-%m-%d')" cehnstrom@techsquare.com < $report_file
mail -s "IPMI ERRORS - $(date +'%Y-%m-%d')" cehnstrom@techsquare.com < $err_file
