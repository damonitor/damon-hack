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

# echo "range	damon	mm	damon/mm	linux	damon/linux"
echo "range	damon	mm	damon/mm"
versions=( $(cat "$stat_branches") )
prev_version="${versions[0]}"
for version in "${versions[@]:1}"
do
	range="$prev_version..$version"
	nr_lines_damon=$("$bindir/_stat_lines.sh" "$range" mm/damon/ \
		--no-merges | awk '{print $3}')
	nr_lines_mm=$("$bindir/_stat_lines.sh" "$range" mm/ \
		--no-merges | awk '{print $3}')
	damon_per_mm=$(awk "BEGIN {printf \"%.2f%%\", \
		$nr_lines_damon * 100 / $nr_lines_mm}")
	line="$range	$nr_lines_damon	$nr_lines_mm	$damon_per_mm"
#	line+="	skip	skip"
	echo "$line"

	prev_version=$version
done
range="${versions[0]}..${versions[-1]}"
nr_lines_damon=$("$bindir/_stat_lines.sh" "$range" mm/damon/ \
	--no-merges | awk '{print $3}')
nr_lines_mm=$("$bindir/_stat_lines.sh" "$range" mm/ \
	--no-merges | awk '{print $3}')
damon_per_mm=$(awk "BEGIN {printf \"%.2f%%\", \
	$nr_lines_damon * 100 / $nr_lines_mm}")
# nr_lines_linux=$("$bindir/_stat_lines.sh" "$range" ./ \
# 	--no-merges | awk '{print $3}')
# damon_per_linux=$(awk "BEGIN {printf \"%.2f%%\", \
# 	$nr_lines_damon * 100 / $nr_lines_linux}")

line="$range	$nr_lines_damon	$nr_lines_mm	$damon_per_mm"
# line+="	$nr_lines_linux	$damon_per_linux"
echo "$line"
