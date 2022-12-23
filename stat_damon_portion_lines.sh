#!/bin/bash

if [ $# -ne 1 ]
then
	echo "Usage: $0 <linux dir>"
	exit 1
fi

bindir=$(realpath $(dirname "$0"))
linux_dir=$1
cd "$linux_dir"

versions=( $(cat "$bindir/stat_branches") )
prev_version="${versions[0]}"
for version in "${versions[@]:1}"
do
	range="$prev_version..$version"
	echo "# $range"
	echo "$("$bindir/_stat_damon_lines_portion.sh" "$range" mm) # mm"
	echo

	prev_version=$version
done
range="${versions[0]}..${versions[-1]}"
echo "# $range"
echo "$("$bindir/_stat_damon_lines_portion.sh" "$range" mm) # mm"
echo "$("$bindir/_stat_damon_lines_portion.sh" "$range" ./) # linux"
