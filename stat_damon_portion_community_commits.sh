#!/bin/bash

if [ $# -ne 2 ]
then
	echo "Usage: $0 <linux dir> <stat branches>"
	exit 1
fi

bindir=$(realpath $(dirname "$0"))
linux_dir=$1
stat_branches=$(realpath "$2")
cd "$linux_dir"

pr_stat()
{
	if [ $# -ne 1 ]
	then
		echo "Usage: $0 <revision range>"
		exit 1
	fi

	range=$1
	from_sj=$(git log "$range" --oneline --author=SeongJae -- \
		$("$bindir/damon_source_files.py") \
		| wc -l)
	from_comm=$(git log "$range" --oneline \
		--perl-regexp --author='^((?!SeongJae).*)$' -- \
		$("$bindir/damon_source_files.py") \
		| wc -l)
	portion=$(awk "BEGIN {printf \"%.2f%%\", \
		${from_comm} * 100 / (${from_sj} + ${from_comm})}")
	echo "$range	$from_sj	$from_comm	$portion"
}

echo "range	from_sj		non_sj	non_sj_portion"
versions=( $(cat "$stat_branches") )
prev_version="${versions[0]}"
for version in "${versions[@]:1}"
do
	pr_stat "$prev_version..$version"
	prev_version=$version
done

pr_stat "${versions[0]}..${versions[-1]}"
