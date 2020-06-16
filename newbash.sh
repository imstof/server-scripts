#!/bin/bash
#Create an new bash file and set permissions
FILE=$1.sh
echo "#!/bin/bash" >> $FILE
echo "" >> $FILE

echo "#SCRIPT DESCRIPTION" >> $FILE
echo "" >> $FILE
echo "show_help(){" >> $FILE
echo "	echo" >> $FILE
echo "	echo \"Usage: \`basename \$0\` #USEAGE DESCRIPTION\"" >> $FILE
echo "	echo \"#HELP DESCRIPTION\"" >> $FILE
echo "	echo" >> $FILE
echo "	echo \"	-h\"" >> $FILE
echo "	echo \"		display this help and exit\"" >> $FILE
echo "	echo" >> $FILE
echo "}" >> $FILE
echo "" >> $FILE
echo "while getopts :: opt #ENTER OPTIONS" >> $FILE
echo "do" >> $FILE
echo "	case \$opt in" >> $FILE
echo "		n)" >> $FILE
echo "			nodes=\$OPTARG" >> $FILE
echo "			;;" >> $FILE
echo "		h)" >> $FILE
echo "			show_help" >> $FILE
echo "			;;" >> $FILE
echo "		\?)" >> $FILE
echo "			echo \"Invalid option -\$OPTARG\"" >> $FILE
echo "			echo \"Try \`basename \$0\` -h\ for help\"" >> $FILE
echo "			exit 1" >> $FILE
echo "			;;" >> $FILE
echo "	esac" >> $FILE
echo "done" >> $FILE

chmod 774 $FILE
vim $FILE
