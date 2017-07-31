#!/bin/bash

scontrol -a show node node$1 | grep -i DOWN > ~/downcheck$1.txt

if [[ -n $(cat ~/downcheck$1.txt) ]]
then
	echo "Node"$1" is DOWN." | mail -s "node"$1" down." -a ~/downcheck$1.txt cehnstrom@techsquare.com
else
	echo "Node"$1" is UP." | mail -s "node"$1" up." -a ~/downcheck$1.txt cehnstrom@techsquare.com
fi

sleep 5
rm ~/downcheck$1.txt
