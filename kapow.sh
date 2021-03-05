#!/bin/bash

#make sure freeipmi module is loaded
[[ -z $(module list 2>&1 | grep freeipmi) ]] && module add freeipmi/1.3.4

#if powering off first check state && queue

if [[ $2 == "f" ]]
then
echo checking nodes...
scontrol show node $1 | grep State
squeue -w $1
read -t 10 -p "OK to power off? " yn
[[ $? -gt "128" ]] && echo aborting && exit 0
[[ $yn == "y" ]] &&
ipmipower -Dlanplus -uroot -pcalvin -h $1.ipmi.cluster -$2 ||
echo aborting
exit 0
else
ipmipower -Dlanplus -uroot -pcalvin -h $1.ipmi.cluster -$2
fi
