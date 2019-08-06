#!/bin/bash

# Keep an eye on a node's queue and text/email when it is empty (for now)
# takes one arg = the node

[[ -z $(for job in $(squeue -haw $1 | awk '{print $1}');do scontrol show job $job | grep EndTime;done) ]] && echo queue is empty at $(date) | mail -s "drain $1 NOW!!" 4136870285@vtext.com -c cehnstrom@techsquare.com

#todo: email when latest endtime -lt some value
