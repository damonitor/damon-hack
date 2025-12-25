#!/bin/bash

set -e

if [ $# -ne 2 ] && [ $# -ne 3 ]
then
	echo "Usage: $0 <revision range> <dir> [--no-merges]"
	exit 1
fi

range=$1
parent_dir=$2

no_merges_option=""
if [ $# -eq 3 ] && [ "$3" = "--no-merges" ]
then
	no_merges_option="--no-merges"
fi

inserts_total=0
deletes_total=0
git_log="git log $no_merges_option"
stats=$($git_log "$range" --shortstat --pretty="" -- "$parent_dir")
while read line
do
	if echo "$line" | grep insertions --quiet && \
		echo "$line" | grep deletion --quiet
	then
		# Eg, 1 file changed, 154 insertions(+), 2 deletions(-)
		inserts=$(echo "$line" | awk '{print $4}')
		deletes=$(echo "$line" | awk '{print $6}')
	elif echo "$line" | grep insertions --quiet
	then
		# Eg, 1 file changed, 54 insertions(+)
		inserts=$(echo "$line" | awk '{print $4}')
		deletes=0
	else
		# 1 file changed, 8 deletions(-)
		inserts=0
		deletes=$(echo "$line" | awk '{print $4}')
	fi
	inserts_total=$((inserts_total + inserts))
	deletes_total=$((deletes_total + deletes))
done <<< "$stats"

echo "$inserts_total $deletes_total $((inserts_total + deletes_total))"
