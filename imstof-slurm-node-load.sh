#!/bin/bash

# rewrite of slurm load script

# create temp files
load_dir=$(mktemp -d `basename $0`.XXX)
load_data=$(mktemp $load_dir/`basename $0`.XXX.txt)
load_report=$(mktemp $load_dir/`basename $0`.XXX.txt)

# help func
show_help() {
	echo
	echo "Usage: `basename $0` [option...]"
	echo "Generate report of nodes with high cpu loads"
	echo
	echo "	-t	echo to terminal (no mail)"
	echo "	-h	disply this help and exit"
	echo
}

# set opts
nomail=false
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
			echo "Invalid option $OPTARG"
			echo "Try '`basename $0` -h' for help"
			exit 1
			;;
	esac
done

# pull nodename,cpus,load,state to file
sinfo -h -t alloc,idle -o %n=%C/=%O=%T | cut -d'/' -f1,5 | sed 's/\///' >> $load_data

# report problem nodes
echo $(date +"%Y-%m-%d") >> $load_report
echo
echo " NODE   CPUS  LOAD    STATE" >> $load_report
echo "============================" >> $load_report
echo

for i in $(cat $load_data)
do
	cores=$(echo $i | awk -F "=" '{printf "%s\n", $2}')
	load=$(echo $i | awk -F "=" '{printf "%s\n", $3}')
	state=$(echo $i | awk -F "=" '{printf "%s\n", $4}')
# report if load is greater than 2 on idle node
	if [[ $(echo $load '> 2' | bc) == 1 && $state == "idle" ]]
	then
		echo $i | awk -F "=" '{printf "%-9s%-4s%1-10s%s\n",$1,$2,$3,$4}' >> $load_report
# report if load is greater than cores+((0.1)cores)
#	elif [[ $(echo $load '>' 100 | bc) == 1 ]]
	elif [[ $cores -gt 0 && $(echo $cores '*0.1+' $cores '<' $load | bc) == 1 ]]
	then
		echo $i | awk -F "=" '{printf "%-9s%-4s%1-10s%s\n",$1,$2,$3,$4}' >> $load_report
	fi
done

# display or mail report
if ( $nomail == true )
then
	cat $load_report
else
	mail -s	"slurm-daily-node-load LOAD $(hostname) $(date +"%Y-%m-%d")" cehnstrom@techsquare.com < $load_report
fi

# remove tmp files
trap 'rm -r $load_dir' EXIT
