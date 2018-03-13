#!/bin/bash

for i in 7.{37..56} 9.{30..41};do
	echo "setting 192.168.$i"
	racadm -r 192.168.$i -u root -p calvin sensorsettings set idrac.embedded.1#systemboardinlettemp -level max 30 2>/dev/null

	ipmitool -I lanplus -H 192.168.$i -U root -P calvin sel clear 2>/dev/null
done
