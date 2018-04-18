#!/bin/bash

#gather logs from crashed sciortino nodes and move to /home/jwright

#help func
show_help(){
	echo
	echo "Usage: `basename $0` [option...]"
	echo "Monitor host(s) and send email when drained"
	echo
	echo "	-n NODESET"
	echo "		nodeset to get logs from"
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
	echo "need some nodes"
	echo "try '`basename $0` -h' for help"
	exit 1
fi

file=/home/jwright/sciortino_nodefail_logs_$(date +"%Y%m%d-%H%M").tar
#file=/home/imstof/sciortino_nodefail_logs_$(date +"%Y%m%d-%H%M").tar

for node in $(nodeset -e $nodes)
do
	nfile=/home/imstof/sciorcrash/$node-logs-$(date +"%Y%m%d-%H%M").tar
	ssh $node "cd /var/log;tar -cf $nfile messages dmesg slurmd"
done

cd /home/imstof/sciorcrash
tar -cf $file *.tar
chown jwright:jwright $file
#chown imstof:imstof $file

rm /home/imstof/sciorcrash/*
