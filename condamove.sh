#!/bin/bash

echo "Here's how to do it:
\`\`\`rsync -huav /home/$1/anaconda3/ /scratch/users/$1/anaconda3/\`\`\`
(make sure you have the trailing slashes)
Then check to see it all copied correctly with
\`\`\`diff  /home/$1/anaconda3/ /scratch/users/$1/anaconda3/\`\`\`
No output means everything is the same on both ends. Then remove the /home dir
\`\`\`rm -r /home/$1/anaconda3/\`\`\`
and set a soft link to the /scratch dir
\`\`\`ln -s /scratch/users/$1/anaconda3 /home/$1/anaconda3"\`\`\`
