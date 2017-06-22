#!/bin/bash
#define paths!

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
			echo "Invalid option: -$OPTARG"
			echo "Try '`basename $0` -h' for help"
			exit 1
			;;
	esac
done

# create temp file(s)
file0=$(mktemp $())

# pull reason,user,timestamp,state,node from sinfo

# use -t for states!
# use mktemp!
# capture sterr!

sinfo -o '%E=%u=%H=%t=%N' | grep -e down -e drain -e drng -e maint > /tmp/sinfo_out.txt

# format output in file for email or echo
echo $(date +"%Y-%m-%d") >> /tmp/status_report.txt
echo >> /tmp/status_report.txt
echo "=== DOWN ===" >> /tmp/status_report.txt
cat /tmp/sinfo_out.txt | awk -F "=" '/down/ {printf "%-23.20s%-7.5s%-22s%-8s%s.\n", $1,$2,$3,$4,$5}' >> /tmp/status_report.txt
echo >> /tmp/status_report.txt
echo "=== DRAIN WITH ISSUES ===" >> /tmp/status_report.txt
cat /tmp/sinfo_out.txt | awk -F "=" '/drain|drng|maint/ {if ($1 != toupper($1)) printf "%-23.20s%-7.5s%-22s%-8s%s\n", $1,$2,$3,$4,$5}' >> /tmp/status_report.txt
echo >> /tmp/status_report.txt
echo "=== DRAIN ON PURPOSE ===" >> /tmp/status_report.txt
cat /tmp/sinfo_out.txt | awk -F "=" '/drain|drng|maint/ {if ($1 == toupper($1)) printf "%-23.20s%-7.5s%-22s%-8s%s\n", $1,$2,$3,$4,$5}' >> /tmp/status_report.txt
echo >> /tmp/status_report.txt
echo "=== Jobs stuck in CG State ===" >> /tmp/status_report.txt
#pipe through awk in case job_name has "CG" in string
#test other than any CG at time script runs?
#squeue | awk '$5 == "CG"' >> /tmp/status_report.txt
squeue | grep CG | tr -s ' ' | awk '{printf "%-9s%-11.9s%-12.10s%-10.8s%-4s%-9.7s%s\n",$1,$2,$3,$4,$5,$6,$8}' >> /tmp/status_report.txt
echo >> /tmp/status_report.txt
echo "=== Active Reservations ===" >> /tmp/status_report.txt
sinfo -T | grep ACTIVE >> /tmp/status_report.txt

# send report to mail-list or echo
if [[ $nomail == true ]]
then
	cat /tmp/status_report.txt
else
	mail -s "slurm-daily-node-status STATUS $(hostname) $(date +"%Y-%m-%d")" cehnstrom@techsquare.com < /tmp/status_report.txt
fi

# trap statement to rm temp files on exit
rm /tmp/sinfo_out.txt
rm /tmp/status_report.txt
