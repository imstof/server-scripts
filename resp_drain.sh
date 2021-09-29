#!/bin/bash

#drain and power off nodes that are not responding
#make sure freeipmi module is loaded
[[ -z $(module list 2>&1 | grep freeipmi) ]] && module add freeipmi/1.3.4

#get nodes, abort if empty
NODES=$(/cm/shared/admin/bin/slurm-daily-node-status -t | awk '/Not resp/ {print $NF}' | nodeset -f)
[[ -z $NODES ]] && echo "No unresponsive nodes. Aborting" && exit 0

#set to drain
echo "setting $NODES to drain..."
scontrol update state=drain reason=not_responding node=$NODES

#check state & queue then power off
echo checking nodes...
scontrol show node $NODES | grep State
squeue -w $NODES
read -t 10 -p "OK to power off? " yn
[[ $? -gt "128" ]] && echo aborting power off && exit 0
[[ $yn == "y" ]] &&
ipmipower -Dlanplus -uroot -pcalvin -h $NODES.ipmi.cluster -f ||
echo aborting power off

echo "Waitng 30s to power on"
sleep 30
ipmipower -Dlanplus -uroot -pcalvin -h $NODES.ipmi.cluster -n
