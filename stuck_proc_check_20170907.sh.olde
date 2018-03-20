#!/bin/bash

NODES=$(sort /home/imstof/.temp/stuck_c3ddb.txt | cut -d' ' -f1)

for NODE in $NODES
do
	echo $NODE
	echo $(ssh $NODE 'ps aux | tr -s " " | cut -d" " -f1,2 | grep msalexis')
done
