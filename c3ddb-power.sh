#!/bin/bash

# script to power on compute nodes at X second intervals

# LEARN GETOPTS TO SET FLAGS FOR TIME INTERVAL, NODE RANGE
# For now, I'm hard-coding those variables

for i in {001..008} {019..098} {300..331}
do
	ipmipower -h node$i.ipmi.cluster -u root -p calvin -D lanplus --on
	sleep 5
done
