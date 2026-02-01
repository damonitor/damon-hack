#!/bin/bash

set -e

bindir=$(dirname "$0")
damon_hack_dir=$(realpath "${bindir}/../")
linux_dir=$(realpath "${bindir}/../../linux")
mm_tree_summary=$(realpath \
	"${bindir}/../../lazybox/linux_hack/mm_tree_summary.py")

summary_dir=${damon_hack_dir}/patches/mm/summary
if [ ! -d "$summary_dir" ]
then
	mkdir -p "$summary_dir"
fi

"$mm_tree_summary" --linux_dir "$linux_dir" --subsystem DAMON \
	--export_info "${summary_dir}/commits_info.json" > \
	"${summary_dir}/summary"

git -C "$bindir" add "$summary_dir"
git commit -s -m "update mm tree status

This is generated via $(basename "$0")"
