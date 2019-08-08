#!/bin/bash

# see which node will end soonest for draining
# takes one arg = nodeset

echo "checking jobs..."

NODES=$(nodeset -e $1)
SOONEST=""
NODE=""

# Get value of latest job finish
for node in $NODES
do
	ENDT=$(for endt in $(squeue -haw $node -o %e);do date -d $endt +%Y%m%d%H%M;done | sort -ru | paste -s | awk '{print $1}')

	[[ -z $NODE ]] && NODE=$node
	[[ -z $SOONEST ]] && SOONEST=$ENDT
	[[ $ENDT -lt $SOONEST ]] && SOONEST=$ENDT && NODE=$node

	#test
#	echo $node
#	echo "ENDT=$ENDT"
#	echo "SOONEST=$SOONEST on $NODE"
done

echo -n "$NODE will be finished soonest"
