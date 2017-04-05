#!/bin/bash
#Create an new bash file and set permissions

FILE=$1.sh
echo "#!/bin/bash" >> $FILE
echo "" >> $FILE
chmod 774 $FILE
vim $FILE
