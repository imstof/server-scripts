#!/bin/bash

#watch node for drained state

#help func
show_help(){
	echo
	echo "Usage: `basename $0` [option...]"
	echo "Monitor host and send email when drained"
	echo
	echo "	-n HOSTNAME"
	echo "		hostname to be monitored"
	echo "	-h"
	echo "		display this help and exit"
	echo
}

while getopts :hn: opt
do
	case $opt in
		n)
			nodes=$OPTARG
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
#check for crontab entry and insert if needed
	if [[ -z $(crontab -l | grep "drain-watch -n $node") ]]
	then
		if [[ -z $(crontab -l) ]]
#if crontab is empty sed '$ a\' won't work. echo the single line to crontab
		then
			echo "*/15 7-18 * * 1-5 /home/imstof/bin/drain-watch -n $node" | crontab -
		else
#else add the line to crontab
			crontab -l | sed "$ a\*\/15 7-18 * * 1-5 \/home\/imstof\/bin\/drain-watch -n $node" | crontab -
		fi
	else
#check for drained state
		if [[ -z $(scontrol -a show node $node | grep -e State=IDLE+DRAIN -e "State=IDLE\*+DRAIN") ]]
		then
#if drained then send mail and remove crontab line
		echo "Node $node is drained" | mail -s "$node drained" cehnstrom@techsquare.com < echo $(scontrol -a show node $node | grep -e State=IDLE+DRAIN -e "State=IDLE\*+DRAIN")
		crontab -l | sed "/watch-node -n $node/d" | crontab -
		fi
	fi
done
