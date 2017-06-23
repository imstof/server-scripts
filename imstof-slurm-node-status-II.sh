#!/bin/bash
#define paths
export PATH=$PATH:/usr/bin/

# slurm daily node status rewrite

#help func
show_help() {
	echo
	echo "Usage: `basename $0` [option...]"
	echo "Generate report of problem nodes and mail to admin"
	echo
	echo "   -t	echo to terminal (no mail)"
	echo "   -h	display this help and exit"
	echo
}

#trap action func
# using temp dir and single action trap instead
#cleanup() {
#	rm $info_file
#	rm $report_file
#}

#variables and temp files
nomail=false
dir0=$(mktemp -d `basename $0`.XXX)
info_file=$(mktemp $dir0/XXX.txt)
report_file=$(mktemp $dir0/XXX.txt)

# set variable for -t flag
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


# pull reason,user,timestamp,state,node from sinfo

sinfo -t down,drain,drng,maint -o '%E=%u=%H=%t=%N' > $info_file 2>&1

# format output in file for email or echo
echo $(date +"%Y-%m-%d") >> $report_file
echo >> $report_file
echo "=== DOWN ===" >> $report_file
cat $info_file | awk -F "=" '/down/ {printf "%-23.20s%-7.5s%-22s%-8s%s.\n", $1,$2,$3,$4,$5}' >> $report_file 2>&1
echo >> $report_file
echo "=== DRAIN WITH ISSUES ===" >> $report_file
cat $info_file | awk -F "=" '/drain|drng|maint/ {if ($1 != toupper($1)) printf "%-23.20s%-7.5s%-22s%-8s%s\n", $1,$2,$3,$4,$5}' >> $report_file 2>&1
echo >> $report_file
echo "=== DRAIN ON PURPOSE ===" >> $report_file
cat $info_file | awk -F "=" '/drain|drng|maint/ {if ($1 == toupper($1)) printf "%-23.20s%-7.5s%-22s%-8s%s\n", $1,$2,$3,$4,$5}' >> $report_file 2>&1
echo >> $report_file
echo "=== Jobs stuck in CG State ===" >> $report_file
#pipe through awk in case job_name has "CG" in string? yes!
squeue | tr -s ' ' | awk -F " " '{if ($5 == "CG") printf "%-9s%-11.9s%-12.10s%-10.8s%-4s%-9.7s%s\n",$1,$2,$3,$4,$5,$6,$8}' >> $report_file 2>&1

#squeue | grep CG | tr -s ' ' | awk '{printf "%-9s%-11.9s%-12.10s%-10.8s%-4s%-9.7s%s\n",$1,$2,$3,$4,$5,$6,$8}' >> $report_file 2>&1
echo >> $report_file
echo "=== Active Reservations ===" >> $report_file
sinfo -T | grep ACTIVE >> $report_file 2>&1

# send report to mail-list or echo
if [[ $nomail == true ]]
then
	cat $report_file
else
	mail -s "slurm-daily-node-status STATUS $(hostname) $(date +"%Y-%m-%d")" cehnstrom@techsquare.com < $report_file
fi

# trap statement to rm temp files on exit
trap 'rm -r $dir0' EXIT
