#!/bin/bash

#send email when jobid runs

show_help(){
	echo
	echo "Usage: `basename $0` #USEAGE DESCRIPTION"
	echo "#HELP DESCRIPTION"
	echo
	echo "	-h"
	echo "		display this help and exit"
	echo
}

while getopts :j: opt #ENTER OPTIONS
do
	case $opt in
		j)
			jobid=$OPTARG
			;;
		h)
			show_help
			;;
		\?)
			echo "Invalid option -$OPTARG"
			echo "Try `basename $0` -h\ for help"
			exit 1
			;;
	esac
done

[[ -z $jobid ]] && echo "need a jobid, dude" && exit 0 

[[ -z $(squeue -htr | grep $jobid) ]] && exit 0 || echo "$jobid is running." | mail -s "$jobid is running" cehnstrom@techsquare.com
