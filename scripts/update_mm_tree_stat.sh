#!/bin/bash

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

mm_patches_dir=${damon_hack_dir}/patches/mm
summary_dir=${mm_patches_dir}/summary

git -C "$bindir" rm -r "$mm_patches_dir"

mkdir -p "$summary_dir"

"$mm_tree_summary" --linux_dir "$linux_dir" \
	--export_info "${summary_dir}/commits_info.json" \
	--save_patches "$mm_patches_dir"

"$mm_tree_summary" --linux_dir "$linux_dir" \
	--import_info "${summary_dir}/commits_info.json" \
	--filter allow subsystem DAMON > "${summary_dir}/summary"

"$mm_tree_summary" --linux_dir "$linux_dir" \
	--import_info "${summary_dir}/commits_info.json" \
	--filter allow subsystem DAMON \
	--full_commits_list > "${summary_dir}/commits_list"

"$mm_tree_summary" --linux_dir "$linux_dir" \
	--import_info "${summary_dir}/commits_info.json" \
	--filter reject not subsystem DAMON \
	--filter reject author "SeongJae Park <sj@kernel.org>" \
	--filter allow not reviewer "SeongJae Park <sj@kernel.org>" \
	--full_commits_list > "${summary_dir}/sj_to_review"

git -C "$bindir" add "$mm_patches_dir"
git -C "$bindir" commit -s -m "patches/mm: update

This is generated via $(basename "$0")"

echo
echo "DAMON patches review stat"
echo "========================="
echo
cat "${summary_dir}/summary"
echo
echo "# for full info, read ${summary_dir}/commits_list"

echo
echo "SJ to review"
echo "============"
echo
cat "${summary_dir}/sj_to_review"
