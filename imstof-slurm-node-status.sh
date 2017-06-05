#!/bin/bash

# slurm daily node status rewrite

#help func
show_help () {
	echo
	echo "Usage: `basename $0` [option...]"
	echo "Generate report of problem nodes and mail to admin"
	echo
	echo "   -t	echo to terminal (no mail)"
	echo "   -h	display this help and exit"
	echo
}

# set variable for -t flag
NOMAIL=false
while getopts :ht opt
do
	case $opt in
		t)
			NOMAIL=true
			;;
		h)
			show_help
			exit 0
			;;
		\?)
			echo "Invalid option: $OPTARG"
			echo "Try '`basename $0` -h' for help"
			exit 1
			;;
	esac
done

# pull reason,user,timestamp,state,node from sinfo
sinfo -o '%E=%u=%H=%t=%N' | grep -e down -e drain -e drng -e maint > ~/.temp/sinfo_out.txt

# format output in file for email or echo
echo $(date +"%Y-%m-%d") >> ~/.temp/status_report.txt
echo >> ~/.temp/status_report.txt
echo "=== DOWN ===" >> ~/.temp/status_report.txt
cat ~/.temp/sinfo_out.txt | awk -F "=" '/down/ {printf "%-23.20s%-7.5s%-22s%-8s%s.\n", $1,$2,$3,$4,$5}' >> ~/.temp/status_report.txt
echo >> ~/.temp/status_report.txt
echo "=== DRAIN WITH ISSUES ===" >> ~/.temp/status_report.txt
cat ~/.temp/sinfo_out.txt | awk -F "=" '/drain|drng|maint/ {if ($1 != toupper($1)) printf "%-23.20s%-7.5s%-22s%-8s%s\n", $1,$2,$3,$4,$5}' >> ~/.temp/status_report.txt
echo >> ~/.temp/status_report.txt
echo "=== DRAIN ON PURPOSE ===" >> ~/.temp/status_report.txt
cat ~/.temp/sinfo_out.txt | awk -F "=" '/drain|drng|maint/ {if ($1 == toupper($1)) printf "%-23.20s%-7.5s%-22s%-8s%s\n", $1,$2,$3,$4,$5}' >> ~/.temp/status_report.txt
echo >> ~/.temp/status_report.txt
echo "=== Jobs stuck in CG State ===" >> ~/.temp/status_report.txt
#pipe through awk in case job_name has "CG" in string
#test other than any CG at time script runs?
#squeue | awk '$5 == "CG"' >> ~/.temp/status_report.txt
squeue | grep CG | tr -s ' ' | awk '{printf "%-9s%-11.9s%-12.10s%-10.8s%-4s%-6s%s\n",$1,$2,$3,$4,$5,$6,$8}' >> ~/.temp/status_report.txt
echo >> ~/.temp/status_report.txt
echo "=== Active Reservations ===" >> ~/.temp/status_report.txt
sinfo -T | grep ACTIVE >> ~/.temp/status_report.txt

# send report to mail-list or echo
if [[ $NOMAIL == true ]]
then
	cat ~/.temp/status_report.txt
else
	mail -s "slurm-daily-node-status STATUS $(hostname) $(date +"%Y-%m-%d")" cehnstrom@techsquare.com < ~/.temp/status_report.txt
fi

rm ~/.temp/sinfo_out.txt
rm ~/.temp/status_report.txt
