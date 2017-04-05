#!/bin/bash

# filter out a pid and kill it

ps aux | awk -F " " "/$1/ {print\$2;}" | xargs kill 2>/dev/null
