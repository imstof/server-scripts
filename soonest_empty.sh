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

echo "$NODE will be finished soonest"
echo -n "current end time is: "
echo $(date -d "${SOONEST:4:2}/${SOONEST:6:2}/${SOONEST:0:4} ${SOONEST:8:2}:${SOONEST:10:2}")
