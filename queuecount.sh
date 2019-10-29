#!/bin/bash

#help function
show_help(){
	echo
	echo "Usage: `basename $0` [option]"
	echo "Summarize number of jobs by user."
	echo
	echo "  -t JOB_STATE"
	echo "		Show only jobs in certain state. Any squeue job state code is viablei."
	echo "  -h"
	echo "		Display this help and exit."
	echo
}

while getopts :ht: opt
do
	case $opt in
		t)
			job_state=$OPTARG
			;;
		h)
			show_help
			exit 0
			;;
		\?)
			echo "Invalid option -$OPTARG"
			echo "Try `basename $0` -h for help"
			exit 1
			;;
	esac
done

for user in $(squeue -h | awk '{print $4}' | sort -u)
do
	luser=$(echo "user; list user" | cmsh | grep $user | awk '{print $1}')
	for userq in $luser
	do
		echo -n $userq" "
		[[ -z $job_state ]] && squeue -hu $userq | wc -l || squeue -hu $userq -t $job_state | wc -l
	done
done
