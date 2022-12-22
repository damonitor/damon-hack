#!/bin/bash

bindir=$(dirname "$0")

prev_version=v5.14
for version in v5.15 v5.16 v5.17 v5.18 v5.19 v6.0 v6.1 linus/master
do
	range="$prev_version..$version"
	echo "# $range"
	echo "$("$bindir/_stat_damon_nr_commits_portion.sh" "$range" mm) # mm"
	echo "$("$bindir/_stat_damon_nr_commits_portion.sh" "$range" ./) # linux"
	echo

	prev_version=$version
done
range="v5.14..linus/master"
echo "# $range"
echo "$("$bindir/_stat_damon_nr_commits_portion.sh" "$range" mm) # mm"
echo "$("$bindir/_stat_damon_nr_commits_portion.sh" "$range" ./) # linux"
