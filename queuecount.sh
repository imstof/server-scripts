#!/bin/bash

for user in $(squeue -h | awk '{print $4}' | sort -u)
do
	luser=$(echo "user; list user" | cmsh | grep $user | awk '{print $1}')
	echo -n $luser" "
	squeue -hu $luser | wc -l
done
