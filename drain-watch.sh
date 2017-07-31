#!/bin/bash

# monitor nodes and send email when idle+drain

#help func
show_help(){
	echo
	echo "Usage: `basename $0` [option...]"
	echo "Monitor host(s) and send email when drained"
	echo
	echo "	-n HOSTNAME"
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
			exit 0
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

# expand nodeset
nodes_ex=$(nodeset -e $nodes)

for node in $nodes_ex
do
# check state
	if [[ -n $(scontrol -a show node $node | grep -e IDLE+DRAIN -e "IDLE\*+DRAIN") ]]
	then
		file=$(mktemp `basename $0`.XXXXXX)
		scontrol -a show node $node > $file 2>&1
		echo "$node is ready." | mail -s "$node is ready" cehnstrom@techsquare.com < $file 2>&1
		rm $file 2>&1
# add node to list for removal from nodeset
		rm_node=$(echo $rm_node $node)
	fi
done

# remove drained nodes from nodeset
for node in $rm_node
do
	nodes_ex=$(echo $nodes_ex | sed "s/$node//")
done

if [[ -z $nodes_ex ]]
then
	exit 0
else
	nodes=$(nodeset -f $nodes_ex)
	at now+$interval <<< /home/imstof/bin/drain-watch -i $interval -n $nodes 2>&1
fi
