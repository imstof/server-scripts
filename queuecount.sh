#!/bin/bash

for user in $(squeue -h | awk '{print $4}' | sort -u)
do
	luser=$(echo "user; list user" | cmsh | grep $user | awk '{print $1}')
	for userq in $luser
	do
		echo -n $userq" "
		squeue -hu $userq | wc -l
	done
done
