#!/bin/bash

# rewrite of slurm load script

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
sinfo -h -t alloc,idle -o %n=%C/=%O=%T | cut -d'/' -f1,5 | sed 's/\///' >> /tmp/load_data.txt

# report problem nodes
echo $(date +"%Y-%m-%d") >> /tmp/load_report.txt
echo
echo " NODE   CPUS  LOAD    STATE" >> /tmp/load_report.txt
echo "============================" >> /tmp/load_report.txt
echo

for i in $(cat /tmp/load_data.txt)
do
	cores=$(echo $i | awk -F "=" '{printf "%s\n", $2}')
	load=$(echo $i | awk -F "=" '{printf "%s\n", $3}')
	state=$(echo $i | awk -F "=" '{printf "%s\n", $4}')
# report if load is greater than 10 on idle node
	if [[ $(echo $load '>' 2 | bc) == 1 && $state == "idle" ]]
	then
		echo $i | awk -F "=" '{printf "%-9s%-4s%1-10s%s\n",$1,$2,$3,$4}' >> /tmp/load_report.txt
# report if load is greater than 100
# percent of cores allocated +10
	elif [[ $(echo $load '>' 100 | bc) == 1 ]]
	then
		echo $i | awk -F "=" '{printf "%-9s%-4s%1-10s%s\n",$1,$2,$3,$4}' >> /tmp/load_report.txt
	fi
done

# display or mail report
if ( $nomail == true )
then
	cat /tmp/load_report.txt
else
	mail -s	"slurm-daily-node-load LOAD $(hostname) $(date +"%Y-%m-%d")" cehnstrom@techsquare.com < /tmp/status_report.txt
fi

# remove tmp files
rm /tmp/load_data.txt
rm /tmp/load_report.txt
