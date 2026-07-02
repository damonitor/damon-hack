#!/bin/bash

damon_next_baseline="mm-new"

if [ $# -ne 1 ] && [ $# -ne 2 ]
then
	echo "Usage: $0 <commit message> [damon/next commit]"
	echo
	echo "e.g., $0 \"rebase on latest mm-new\" HEAD"
	exit 1
fi

bindir=$(dirname $0)
commit_msg=$1

if [ $# -eq 2 ]
then
	damon_next_commit=$2
else
	damon_next_commit="HEAD"
fi

if "$bindir/patches_uptodate.sh" > /dev/null
then
	echo "Patches queue is already up to date."
	exit 1
fi

dest_dir=$(realpath "$bindir/../patches/next")

echo "find baseline"
damon_next_baseline=$("$bindir/get_damon_next_baseline_commit.sh")
if [ "$damon_next_baseline" = "" ]
then
	echo "Fail baseline finding"
	exit 1
fi
commits="$damon_next_baseline..${damon_next_commit}"

commit_msg="$commit_msg

Assembled tree: $(git rev-parse $damon_next_commit)"

echo "git-rm old patches"
git -C "$bindir" rm -r "$dest_dir" > /dev/null
mkdir -p "$dest_dir"

lbx_path=$(realpath "$bindir/../../lazybox")
patches_queue_py="$lbx_path/git_helpers/patches_queue.py"
if [ ! -f "$patches_queue_py" ]
then
	patches_queue_py="$lbx_path/version_control/patches_queue.py"
fi
if [ ! -x "$patches_queue_py" ]
then
	echo "$patches_queue_py not found"
	exit 1
fi

echo "generate new patches"
"$patches_queue_py" \
	--series "${dest_dir}/series" --commits "$commits" --repo ./ \
	> /dev/null

echo "commit new patches"
git -C "$bindir" add "$dest_dir"
git -C "$bindir" commit -s -m "patches/next: $commit_msg"

read -r -p "Wannt review the change? [y/N] " answer
if [ "$answer" = "y" ]
then
	git -C "$bindir" show
fi
