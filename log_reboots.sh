#!/bin/bash

echo $(date) >> /home/imstof/reboots
/cm/shared/admin/bin/slurm-daily-node-status -t | awk '/Not responding/ {print $6}' >> /home/imstof/reboots
