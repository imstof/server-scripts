#!/bin/bash
#A script to start a pythong file and set the executable bit

FILE=$1.py
echo "#!/usr/bin/env python" > $FILE
echo "" >> $FILE
chmod 774 $FILE
vim $FILE
