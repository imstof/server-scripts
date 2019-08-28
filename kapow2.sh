#!/bin/bash

#two args = ip address, status|off|on|cycle

ipmitool -Ilanplus -Uroot -Pcalvin -H $1 power $2
