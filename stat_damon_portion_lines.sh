#!/bin/bash

bindir=$(dirname "$0")

prev_version=v5.14
for version in v5.15 v5.16 v5.17 v5.18 v5.19 v6.0 v6.1 linus/master
do
	range="$prev_version..$version"
	echo "# $range"
	echo "in mm"
	"$bindir/_stat_damon_lines_portion.sh" "$range" mm
	echo
	echo "in linux"
	"$bindir/_stat_damon_lines_portion.sh" "$range" ./
	echo

	prev_version=$version
done
range="v5.14..linus/master"
echo "# $range"
echo "in mm"
"$bindir/_stat_damon_lines_portion.sh" "$range" mm
echo
echo "in linux"
"$bindir/_stat_damon_lines_portion.sh" "$range" ./
echo
