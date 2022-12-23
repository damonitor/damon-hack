#!/bin/bash

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
	echo "$range	$from_sj	$from_comm	$((from_comm * 100 / (from_sj + from_comm))) %"
}

echo "range	from_sj		from_comm	from_comm rate (%)"
versions=( $(cat "$bindir/stat_branches") )
prev_version="${versions[0]}"
for version in "${versions[@]:1}"
do
	pr_stat "$prev_version..$version"
	prev_version=$version
done

pr_stat "${versions[0]}..${versions[-1]}"
