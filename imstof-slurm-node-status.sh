#!/bin/bash

# slurm daily node status rewrite

# pull reason,user,timestamp,state,node from sinfo
sinfo -N -o '%E : %u : %H : %t : %N' | grep -e down -e drain -e drng > ~/.temp/sinfo_out.txt

#format output in file for email or echo
echo $(date +"%Y-%m-%d") >> ~/.temp/status_report.txt
echo "" >> ~/.temp/status_report.txt
echo "=== DOWN ===" >> ~/.temp/status_report.txt
cat ~/.temp/sinfo_out.txt | grep down >> ~/.temp/status_report.txt
echo "" >> ~/.temp/status_report.txt
echo "=== DRAIN WITH ISSUES ===" >> ~/.temp/status_report.txt


rm ~/.temp/sinfo_out.txt
rm ~/.temp/status_report.txt
