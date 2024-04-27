#!/bin/bash

set -e

bindir=$(dirname "$0")
patches_dir="$bindir/patches/next"
series_file="$patches_dir/series"

git checkout akpm.korg.mm/mm-unstable

baseline_ignored="false"
for patch in $(cat "$series_file")
do
	# the first line is the baseline commit hash
	if [ "$baseline_ignored" = "false" ]
	then
		baseline_ignored="true"
		continue
	fi
	git am "$patches_dir/$patch"
done
