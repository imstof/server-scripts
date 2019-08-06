#!/bin/bash

# Keep an eye on a node's queue and text/email when it is empty (for now)
# takes one arg = the node

# check if already idle
[[ -n $(scontrol show node $1 | grep IDLE) ]] && echo queue is empty at $(date) | mail -s "drain $1 NOW!!" 4136870285@vtext.com -c cehnstrom@techsquare.com -c 4135882311@vtext.com && exit 0



# Get value of latest job finish

ENDT=$(for endt in $(squeue -haw $1 -o %e);do date -d $endt +%Y%m%d%H%M;done | sort -ru | paste -s | awk '{print $1}')
NOW=$(date +%Y%m%d%H%M)

#test
#echo $ENDT
#echo $NOW
#echo $(echo $ENDT-$NOW | bc)

[[ $(echo "$ENDT-$NOW | bc") -lt "20001" ]] && echo "$1 last job will finish: $ENDT"| mail -s "$1 queue empty soon" 4136870285@vtext.com -c cehnstrom@techsquare.com -c 4135882311@vtext.com
