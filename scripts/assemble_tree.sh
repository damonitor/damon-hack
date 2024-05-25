#!/bin/bash

set -e

if [ $# -ne 1 ]
then
	echo "Usage: $0 <series file>"
	exit 1
fi

series_file=$(realpath "$1")
patches_dir=$(dirname "$series_file")

baseline_checked_out="false"
for patch in $(cat "$series_file")
do
	# the first line is the baseline commit hash
	if [ "$baseline_checked_out" = "false" ]
	then
		git checkout "$patch"
		baseline_checked_out="true"
		continue
	fi
	git am "$patches_dir/$patch"
done
