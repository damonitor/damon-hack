#!/bin/bash

bindir=$(dirname "$0")

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
prev_version=v5.14
versions="$(cat "$bindir/releases_having_damon") linus/master"
for version in $versions
do
	pr_stat "$prev_version..$version"
	prev_version=$version
done

pr_stat "v5.14..linus/master"
