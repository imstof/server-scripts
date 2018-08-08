#!/bin/bash

# send 5 pings and email when 0% packet loss

#help func
show_help(){
	echo
	echo "Usage: `basename $0` [option...]"
	echo "Test ping of host and email when 0% packet loss is reported"
	echo
	echo "	-n HOSTNAME"
	echo "		hostname(s) to be monitored"
	echo "		can be any combination of node, nodeset, ipv4 addresses, or FQDNs" 
	echo "		seperated by commas (no spaces)"
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
			echo "Invalid option -$OPTARG"
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

for node in $nodelist
do
# check for/add entry to crontab
	if [[ -z $(crontab -l | grep "pingcheck -n $node") ]]
	then
	#sed won't '$ a' to empty crontab, echo the single line
		if [[ -z $(crontab -l) ]]
		then
			echo "*/1 * * * * /home/imstof/bin/pingcheck -n $node" | crontab -
		else
			crontab -l | sed "$ a\*\/1 7-18 * * 1-5 \/home\/imstof\/bin\/pingcheck -n $node" | crontab -
		fi
	fi

	if [[ -n $(ping -qc5 $node | grep ' 100% packet loss') ]]
	then
		echo "ping" | mail -s "$node is not pinging" cehnstrom@techsquare.com
		crontab -l | sed /pingcheck\ -n\ $node/d | crontab -
	fi
done
