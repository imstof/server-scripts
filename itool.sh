#!/bin/bash

#default ipmi creds with ipmitool
#taks 2 args. nodename && "ipmi command"

ipmitool -Ilanplus -Uroot -Pcalvin -H $1.ipmi.cluster $2

