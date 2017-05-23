#!/bin/bash

# script to power on nodes at X second intervals
# LEARN GETOPTS TO SET VARIABLES hard coded for now

for i in {001..016} {019..036} 040 {073..088} {091..094} {100..108} {120..128} {125..128} {131..424} {428..619} {621..761} {942..965}
do
	ipmipower -h node$i.ipmi.cluster -u root -p calvin -D lanplus --on
	sleep 5
done
