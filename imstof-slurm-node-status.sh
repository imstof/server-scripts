#!/bin/bash

# slurm daily node status rewrite

# set variable for -t flag
NOMAIL=false
while getopts :t opt
do
	case $opt in
		t)
			NOMAIL=true
			;;
		/?)
			echo "Invalid option: $OPTARG"
			exit 1
			;;
	esac
done

# pull reason,user,timestamp,state,node from sinfo
# CUT IDLE+ DOWN+
sinfo -N -o '%E:%u:%H:%t:%N' | grep -e down -e drain -e drng -e maint > ~/.temp/sinfo_out.txt

# format output in file for email or echo
echo $(date +"%Y-%m-%d") >> ~/.temp/status_report.txt
echo "" >> ~/.temp/status_report.txt
echo "=== DOWN ===" >> ~/.temp/status_report.txt
cat ~/.temp/sinfo_out.txt | awk -F ":" '/down/ {printf "%-21.20s%-13.10s%-20s%-7s%s.\n", $1,$2,$3,$4,$5}' > ~/.temp/status_report.txt
echo "" >> ~/.temp/status_report.txt
echo "=== DRAIN WITH ISSUES ===" >> ~/.temp/status_report.txt
cat ~/.temp/sinfo_out.txt | awk -F ":" '/drain|drng|maint/ {printf "%-21.20s%-13.10s%-20s%-7s%s\n", $1,$2,$3,$4,$5}'
echo "" >> ~/.temp/status_report.txt
echo "=== DRAIN ON PURPOSE ===" >> ~/.temp/status_report.txt
# CITERI[A,ON] FOR ON PURPOSE?

echo "" >> ~/.temp/status_report.txt
echo "=== Jobs stuck in CG State ===" >> ~/.temp/status_report.txt

# send report to mail-list or echo
# LEARN MORE ABOUT MAIL-LIST
if [[ $NOMAIL == true ]]
then
	cat ~/.temp/status_report.txt
else
	mail -s "slurm-daily-node-status STATUS $(hostname) $(date +"%Y-%m-%d")" cehnstrom@techsquare.com < ~/.temp/status_report.txt
fi

rm ~/.temp/sinfo_out.txt
rm ~/.temp/status_report.txt
