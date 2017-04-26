#!/bin/bash

#put cpu under load

#

while true
do
	for i in $(seq 1 $1)
	do
		echo "2^2^20" | bc &>/dev/null
	done
done
