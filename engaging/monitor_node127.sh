#!/bin/bash

sacct -X -o start,end,state,user -s F,NF -S $(date --date="8 hours ago" +"%F") -N node127 > ~/node127report.txt

if [[ -n $(cat ~/node127report.txt | grep -i fail) ]]
then
	echo "Failure on node127." | mail -s "node127 failure" -a ~/node127report.txt cehnstrom@techsquare.com
else
#	squeue -aw node127 > ~/node127queue.txt
	echo $(squeue -aw node127 > ~/node127queue.txt) | mail -s "node127 okay" -a ~/node127queue.txt cehnstrom@techsquare.com
fi
