#!/bin/bash

# send 5 pings and email when 0% packet loss

#help func
show_help(){
	echo
	echo "Usage: `basename $0` [option...]"
	echo "Test ping of host and email when 0% packet loss is reported"
	echo
	echo "	-n HOSTNAME"
	echo "		hostname to be monitored"
	echo "		can also be IP address or FQDN"
	echo "	-h"
	echo "		display this help and exit"
	echo
}

while getopts :hn: opt
do
	case $opt in
		n)
			node=$OPTARG
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

if [[ -z $node ]]
then
	echo "Option -n must be specified"
	echo "Try '`basename $0` -h' for help"
	exit 1
fi

if [[ -n $(ping -qc5 $node | grep ' 0% packet loss') ]]
then
	echo "ping" | mail -s "$node is pinging" cehnstrom@techsquare.com
	crontab -l | sed /pingcheck\ -n\ $node/d | crontab -
fi
