#!/bin/bash

scontrol -a show node node$1 | grep -e IDLE+DRAIN -e "DOWN\*+DRAIN" -e "IDLE\*+DRAIN" -e DOWN+DRAIN > ~/resumecheck$1.txt
if [[ -n $(cat resumecheck$1.txt) ]]
then
	echo "Node"$1" is still drained." | mail -s "node"$1" still drained." cehnstrom@techsquare.com < ~/resumecheck$1.txt
else
	echo "Node"$1" is resumed." | mail -s "node"$1" resumed." cehnstrom@techsquare.com < ~/resumecheck$1.txt 
fi

sleep 5
rm ~/resumecheck$1.txt
