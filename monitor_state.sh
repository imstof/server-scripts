#!/bin/bash

#crontab entry: */15 6-18 * * 1-5 /home/imstof/bin/monitor_state [node number]
#		0 20,0,4 * * 1-5 /home/imstof/bin/monitor_state [node number]

scontrol -a show node node$1 | grep State=IDLE+DRAIN > ~/statecheck$1.txt
scontrol -a show node node$1 | grep State=DOWN*+DRAIN > ~/statecheck$1.txt
if [[ -n $(cat statecheck$1.txt) ]]
then 
	echo "Node"$1" ready." | mail -s "node"$1" ready." -a ~/statecheck$1.txt cehnstrom@techsquare.com
fi

sleep 5
rm ~/statecheck$1.txt
