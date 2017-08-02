#!/bin/bash

# watch job end-state for node_fail
# TODO:add option for other states/conditions

# help func
show_help(){
o
	echo "Usage: `basename $0` [option...]"
	echo "Monitor host(s) and send email when drained"
	echo
	echo "	-n HOSTNAME"
	echo "		hostname(s) to be monitored"
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
			;;
		\?)
			echo "Invalid option: $OPTARG"
			echo "Try '`basename $0` -h' for help"
			exit 1
			;;
	esac
done

if [[ -z $nodes ]]
then
	echo "option -n must be specified"
	echo "Try '`basename $0` -h' for help"
	exit 1
fi

nodes_ex=$(nodeset -e $nodes)
dir0=$(mktemp -d `basename $0`.XXXXXX)

for node in $nodes_ex
do
	file=$(mktemp $dir0/$node.XXXXXX.txt)
	sacct -nS $(date --date="2 hours ago" +"%m/%d-%T") -s NF -o END,STATE -N $node > $file
	echo $file 		#TEST
	
	if [[ -n $(cat $file) ]]
	then
		mail -s "$node failure" cehnstrom@techsquare.com < $file
	fi
done

trap 'rm -r $dir0' EXIT
