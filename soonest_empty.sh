#!/bin/bash

# see which node will end soonest for draining
# takes one arg = nodeset

echo "checking jobs..."

NODES=$(nodeset -e $1)
SOONEST=""
LATEST=""
SNODE=""

# Get value of latest job finish
for node in $NODES
do
#	ENDTS=$(for endt in $(squeue -haw $node -o %e);do date -d $endt +%Y%m%d%H%M%S;done | sort -u | paste -s | awk '{print $1}')
ENDTS=$(date -d "$(squeue -haw $node -o %e | sort -ru | paste -s | cut -f1 | sed 's/T/ /')" +%Y%m%d%H%M%S)
#	ENDTL=$(for endt in $(squeue -haw $node -o %e);do date -d $endt +%Y%m%d%H%M%S;done | sort -ru | paste -s | awk '{print $1}')
ENDTL=$(date -d "$(squeue -haw $node -o %e | sort -ru | paste -s | cut -f1 | sed 's/T/ /')" +%Y%m%d%H%M%S)

	[[ -z $ENDTS ]] && echo "$node queue is already empty" && break
	[[ -z $SNODE ]] && SNODE=$node
	[[ -z $LNODE ]] && LNODE=$node
	[[ -z $SOONEST ]] && SOONEST=$ENDTS
	[[ -z $LATEST ]] && LATEST=$ENDTL
	[[ $ENDTS -lt $SOONEST ]] && SOONEST=$ENDTS && SNODE=$node
	[[ $ENDTL -gt $LATEST ]] && LATEST=$ENDTL && LNODE=$node

#	test
	echo $node
#	echo "ENDTS=$ENDTS"
#	echo "ENDTL=$ENDTL"
#	echo "SOONEST=$SOONEST on $SNODE"
#	echo "LATEST=$LATEST on $LNODE"

done

echo "$SNODE will be finished soonest"
echo -n "current end time is: "
echo $(date -d "${SOONEST:4:2}/${SOONEST:6:2}/${SOONEST:0:4} ${SOONEST:8:2}:${SOONEST:10:2}:${SOONEST:12:2}")
echo
echo "$LNODE will be finished last"
echo -n "current end time is: "
echo $(date -d "${LATEST:4:2}/${LATEST:6:2}/${LATEST:0:4} ${LATEST:8:2}:${LATEST:10:2}:${LATEST:12:2}")
