#!/bin/bash

if [ $# -ne 1 ]
then
	echo "Usage: $0 <json file to save the stat>"
	exit 1
fi

pypistats overall damo --daily --mirrors without -f json > "$1"
