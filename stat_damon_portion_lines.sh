#!/bin/bash

bindir=$(dirname "$0")

prev_version=v5.14
versions="$(cat "$bindir/releases_having_damon") linus/master"
for version in $versions
do
	range="$prev_version..$version"
	echo "# $range"
	echo "$("$bindir/_stat_damon_lines_portion.sh" "$range" mm) # mm"
	echo

	prev_version=$version
done
range="v5.14..linus/master"
echo "# $range"
echo "$("$bindir/_stat_damon_lines_portion.sh" "$range" mm) # mm"
echo "$("$bindir/_stat_damon_lines_portion.sh" "$range" ./) # linux"
echo
