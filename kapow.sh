#!/bin/bash

ipmipower -Dlanplus -uroot -pcalvin -h $1.ipmi.cluster -$2
