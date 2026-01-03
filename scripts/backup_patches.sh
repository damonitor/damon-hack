#!/bin/bash

damon_next_baseline="mm-new"

if [ $# -ne 2 ]
then
	echo "Usage: $0 <damon/next commit> <commit message>"
	echo
	echo "e.g., $0 \"rebase on latest mm-new"
	exit 1
fi

bindir=$(dirname $0)
damon_next_commit=$1
commit_msg=$2

if "$bindir/patches_uptodate.sh" > /dev/null
then
	echo "Patches queue is already up to date."
	exit 1
fi

dest_dir=$(realpath "$bindir/../patches/next")
damon_next_baseline=$("$bindir/get_damon_next_baseline_commit.sh")
if [ "$damon_next_baseline" = "" ]
then
	echo "Fail baseline finding"
	exit 1
fi
commits="$damon_next_baseline..${damon_next_commit}"

commit_msg="$commit_msg

Assembled tree: $(git rev-parse $damon_next_commit)"

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
