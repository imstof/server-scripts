#!/bin/bash

#two args = node, status|off|on|cycle

ipmitool -Ilanplus -Uroot -Pcalvin -H $1.ipmi.cluster power $2
