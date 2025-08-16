#!/bin/bash

damon_next_baseline="mm-new"

if [ $# -ne 1 ]
then
	echo "Usage: $0 <commit message>"
	echo
	echo "e.g., $0 \"rebase on latest mm-new"
	exit 1
fi

commit_msg=$1
bindir=$(dirname $0)
dest_dir=$(realpath "$bindir/../patches/next")
damon_next_baseline=$("$bindir/get_damon_next_baseline_commit.sh")
if [ "$damon_next_baseline" = "" ]
then
	echo "Fail baseline finding"
	exit 1
fi
commits="$damon_next_baseline..damon/next"

commit_msg="$commit_msg

Assembled tree: $(git rev-parse damon/next)"

git -C "$bindir" rm -r "$dest_dir"
mkdir -p "$dest_dir"

lbx_path=$(realpath "$bindir/../../lazybox")
patches_queue_py="$lbx_path/git_helpers/patches_queue.py"
if [ ! -x "$patches_queue_py" ]
then
	echo "$patches_queue_py not found"
	exit 1
fi

"$patches_queue_py" \
	--series "${dest_dir}/series" --commits "$commits" --repo ./

git -C "$bindir" add "$dest_dir"
git -C "$bindir" commit -s -m "patches/next: $commit_msg"
