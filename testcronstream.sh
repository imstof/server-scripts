#!/bin/bash

crontab - << EOF
* 7 * * * /home/imstof/bin/prog -n test1
* 7 * * * /home/imstof/bin/prog -n test2
* 7 * * * /home/imstof/bin/prog -n test3
* 7 * * * /home/imstof/bin/prog -n test4
EOF
