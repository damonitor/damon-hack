#!/bin/bash

bindir=$(dirname "$0")

versions=( $(cat "$bindir/stat_branches") )
prev_version="${versions[0]}"
for version in "${versions[@]:1}"
do
	range="$prev_version..$version"
	echo "# $range"
	echo "$("$bindir/_stat_damon_nr_commits_portion.sh" "$range" mm) # mm"
	echo "$("$bindir/_stat_damon_nr_commits_portion.sh" "$range" ./) # linux"
	echo

	prev_version=$version
done
range="${versions[0]}..${versions[-1]}"
echo "# $range"
echo "$("$bindir/_stat_damon_nr_commits_portion.sh" "$range" mm) # mm"
echo "$("$bindir/_stat_damon_nr_commits_portion.sh" "$range" ./) # linux"
