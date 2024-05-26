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

versions=( $(cat "$stat_branches") )
prev_version="${versions[0]}"
echo "range	damon	mm	damon/mm	linux	damon/linux"
for version in "${versions[@]:1}"
do
	range="$prev_version..$version"
	nr_commits_damon=$(git log --pretty=%h --no-merges "$range" \
		-- $("$bindir/damon_source_files.py") | wc -l)
	nr_commits_mm=$(git log --pretty=%h --no-merges "$range" \
		-- $("$bindir/mm_source_files.py") | wc -l)
	nr_commits_total=$(git log --pretty=%h --no-merges "$range" | wc -l)

	line="$range	$nr_commits_damon	$nr_commits_mm	"
	line+="$(awk "BEGIN {printf \"%.2f%%\", \
		$nr_commits_damon * 100 / $nr_commits_mm}")"
	line+="	$nr_commits_total	"
	line+="$(awk "BEGIN {printf \"%.2f%%\", \
		$nr_commits_damon * 100 / $nr_commits_total}")"
	echo "$line"
	prev_version=$version
done
range="${versions[0]}..${versions[-1]}"
nr_commits_damon=$(git log --pretty=%h --no-merges "$range" \
	-- $("$bindir/damon_source_files.py") | wc -l)
nr_commits_mm=$(git log --pretty=%h --no-merges "$range" -- mm/ | \
	wc -l)
nr_commits_total=$(git log --pretty=%h --no-merges "$range" | wc -l)

line="$range	$nr_commits_damon	$nr_commits_mm	"
line+="$(awk "BEGIN {printf \"%.2f%%\", \
	$nr_commits_damon * 100 / $nr_commits_mm}")"
line+="	$nr_commits_total	"
line+="$(awk "BEGIN {printf \"%.2f%%\", \
	$nr_commits_damon * 100 / $nr_commits_total}")"
echo "$line"
