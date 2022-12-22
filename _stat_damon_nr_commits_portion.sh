#!/bin/bash

set -e

if [ $# -ne 2 ]
then
	echo "Usage: $0 <revision range> <parent dir>"
	exit 1
fi

range=$1
parent_dir=$2

nr_commits_total=$(git log --pretty=%h --no-merges "$range" -- "$parent_dir" \
	| wc -l)
nr_commits_damon=$(git log --pretty=%h --no-merges "$range" -- mm/damon/ \
	| wc -l)
portion_permil=$((nr_commits_damon * 1000 / nr_commits_total))

echo "$nr_commits_damon/$nr_commits_total ($portion_permil permil) without merge"
