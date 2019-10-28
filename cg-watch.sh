#!/bin/bash

#mail when queue is only CG jobs

show_help(){
	echo
	echo "Usage: `basename $0` -h <hosts> [option...]"
	echo "Monitor queue and send mail when only CG jobs remain"
	echo
	echo "  -n HOSTNAME"
	echo "		hostname(s) to be monitored"
	echo "	-i INTERVAL"
	echo "		interval bewteen checks (defalut 15 min)"
	echo "	-h"
	echo "		display this help and exit"
	echo
}

interval="15 minutes"

while getopts :hn:i: opt
do
	case $opt in
		n)
			nodes=$OPTARG
			;;
		i)
			interval=$OPTARG
			;;
		h)
			show_help
			;;
		\?)
			echo "Invalid option -$OPTARG"
			echo "Try '`basename $0` -h' for help"
			exit 1
			;;
	esac
done

if [[ -z $nodes ]]
then
	echo "option -n must be specified"
	echo "try '`basename $0` -h' for help"
	exit 1
fi

if [[ -z $interval ]]
then
	echo "error: argument expected for option -i"
	echo "try '`basename $0` -h' for help"
	exit 1
fi

nodes_ex=$(nodeset -e $nodes)

for node in $nodes_ex
do
	if [[ -z $(squeue -haw $node | grep -v CG) ]]
	then
		echo "trying to mail"
		echo $node is CG only | mail -s "$node is CG only" cehnstrom@techsquare.com
		rm_node=$(echo $rm_node $node)
	fi
done

for node in $rm_node
do
	nodes_ex=$(echo $nodes_ex | sed "s/$node//")
done

[[ -z $nodes_ex ]] && exit 0

nodes=$(nodeset -f $nodes_ex)
at -M now+$interval <<< "/home/imstof/bin/cg-watch -i \"$interval\" -n $nodes" 2>/dev/null
#at -M now+$interval <<< "/home/imstof/serverscripts/cg-watch.sh -i \"$interval\" -n $nodes"
