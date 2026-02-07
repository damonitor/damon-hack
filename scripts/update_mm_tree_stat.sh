#!/bin/bash

# TODO
# - save all mm.git commits after master as patches
#   - for making DAMON tree always reproducible
# - list of full patches
# - list patches that not authored by SJ but not reviewed by SJ.

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

"$mm_tree_summary" --linux_dir "$linux_dir" \
	--export_info "${summary_dir}/commits_info.json" \
	--filter allow subsystem DAMON > "${summary_dir}/summary"

git -C "$bindir" add "$summary_dir"
git -C "$bindir" commit -s -m "patches/mm/summary: update"

This is generated via $(basename "$0")"
