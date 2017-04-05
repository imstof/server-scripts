#!/bin/bash

history | awk -F " " '{$1=""; print $0}' | uniq
