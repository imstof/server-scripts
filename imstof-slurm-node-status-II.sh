#!/bin/bash

# rewrite of slurm-daily-node-status

# show_help func
show_help(){
	echo
	echo "Usage: `basename $0` [option..]'"
	echo "Generate a report of problem nodes and email to admin"
	echo
	echo "	-t	text only (no mail)"
	echo "	-h	display this help and exit"
	echo
}

nomail=false

# set flag for text only
while getopts :ht opt
do
	case $opt in
		t)
			nomail=true
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
	esac
done

# pull sinfo for down/drain nodes to file
sinfo -R -l | grep -ie down -ie drain -ie drng -ie maint > /tmp/sinfo_out.txt

# generate report
echo $(date +"%Y-%m-%d") >> /tmp/sreport.txt
echo >> /tmp/sreport.txt
echo >> "=== DOWN ===" >> /tmp/sreport.txt
cat /tmp/sinfo_out.txt | grep -i down >> /tmp/sreport.txt
echo >> /tmp/sreport.txt
echo "=== DRAIN WITH ISSUES ===" >> /tmp/sreport.txt
cat /tmp/sinfo_out.txt | awk 
