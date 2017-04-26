#!/bin/bash

while true
do
	i=1

	while [[ i -lt $1 ]]
	do
		./yescpu.sh
		((i++))
	done

	sleep 60
	killall yes
	sleep 8
done &

