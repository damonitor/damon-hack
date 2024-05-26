#!/bin/bash

set -e

if [ $# -ne 2 ]
then
	echo "Usage: $0 <revision range> <parent dir>"
	exit 1
fi

bindir=$(dirname "$0")
range=$1
parent_dir=$2

lines_total=$("$bindir/_stat_lines.sh" "$range" "$parent_dir" --no-merges | \
	awk '{print $3}')
lines_damon=$("$bindir/_stat_lines.sh" "$range" mm/damon/ --no-merges | \
	awk '{print $3}')
portion=$(awk "BEGIN {printf \"%.2f %%\", \
	${lines_damon} * 100 / ${lines_total}}")

portion_bp=$((lines_damon * 10000 / lines_total))
echo "$lines_damon/$lines_total ($portion) without merges"
echo
