#!/bin/bash

for luser in $(squeue -h | awk '{print $4}' | sort -u)
do
	echo -n $luser" "
	squeue -hu $luser | wc -l
done
