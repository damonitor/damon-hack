#!/bin/bash

set -e

if [ $# -ne 1 ]
then
	echo "Usage: $0 <json file to save the stat>"
	exit 1
fi

if [ ! -d pypistats_venv ]
then
	python3 -m venv pypistats_venv
fi

source ./pypistats_venv/bin/activate
if ! which pypistats
then
	pip install pypistats
fi
pypistats overall damo --daily --mirrors without -f json > "$1"
deactivate
