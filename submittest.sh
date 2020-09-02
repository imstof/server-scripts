#!/bin/bash

#send test job to slurm
#TODO:add options

sbatch -n 1 -t 360 -p defq /home/imstof/testjobs/slurmScript.sh primeFinder.py
