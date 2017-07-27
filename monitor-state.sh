#!/bin/bash

#crontab entry: */15 6-18 * * 1-5 /home/imstof/bin/monitor_state [node number]
#		0 20,0,4 * * 1-5 /home/imstof/bin/monitor_state [node number]

# new version to self install/remove crontabs

#help func
show_help(){
	echo
	echo "Usage: `basename $0` [option...]"
	echo "Monitor host(s) and send email when drained"
	echo
	echo "	-n HOSTNAME"
	echo "		hostname(s) to be monitored"
	echo "	-M MINUTES"
	echo "		crontab minutes between checks (default is 15)"
	echo "	-H HOURS"
	echo "		crontab hours (default is '7-18')"
	echo "	-D DAYS"
	echo "		crontab days of week (default is '1-5')"
	echo "	-h"
	echo "		display this help and exit"
	echo
}

mins="15"
hours="7-18"
days="1-5"

while getopts :hn:M:H:D: opt
do
	case $opt in
		n)
			nodes=$OPTARG
			;;
		M)
			mins=$OPTARG
			;;
		H)
			hours=$OPTARG
			;;
		D)
			days=$OPTARG
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

if [[ -z $mins || -z $hours || -z $days ]]
then
	echo "error: argument(s) expected for option(s)"
	echo "try '`basename $0` -h' for help"
	exit 1
fi

crontab -l | sed "/monitor-state*$nodes/d" | crontab -

nodes_ex=$(nodeset -e $nodes)

for node in $nodes_ex
do
	if [[ -n $(scontrol -a show node $node | grep -e IDLE+DRAIN -e "IDLE\*+DRAIN") ]]
	then
		echo "$node is ready." | mail -s "$node is ready" cehnstrom@techsquare.com < $(scontrol -a show node $node)
	rm_node=$(echo $rm_node $node)
	fi
done

nodes=$(nodeset -f $(
	for node in $rm_node
	do
		nodes_ex=$(echo $nodes_ex | sed "s/$node//")
	done
	echo $nodes_ex))

if [[ -n $nodes ]]
then
	#sed won't '$ a' to empty crontab, echo the single line
	if [[ -z $(crontab -l) ]]
	then
		echo "*/$mins $hours * * $days /home/imstof/bin/monitor-state -M $mins -H $hours -D $days -n $nodes" | crontab -
	else
		crontab -l | sed "$ a\*\/$mins $hours * * $days \/home\/imstof\/bin\/monitor-state\ -M\ $mins\ -H\ $hours\ -D\ $days\ -n\ $nodes" | crontab -
	fi
fi
