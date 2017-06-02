#!/bin/bash

scontrol -a show node node[$(cat $1 | tr -s ' ' | cut -d' ' -f2 | sed ':a;N;$!ba;s/\n/,/g' | sed 's/node//g')] | grep -ie nodename -ie reason
