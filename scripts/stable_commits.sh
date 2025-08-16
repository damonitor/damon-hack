#!/bin/bash

# Find commits for stable kernel trees that not merged in appropriate trees
# yet.

bindir=$(dirname "$0")
lbx_path=$(realpath "$bindir/../../lazybox")
stable_commits_check="$lbx_path/linux_hack/stable_commits_check.py"

if [ ! -x "$stable_commits_check" ]
then
	echo "$stable_commits_check not found"
	exit 1
fi

for tree in 5.15 6.1 6.6 6.8
do
	src="v$tree..linus/master"
	dst="v$tree..stable/linux-$tree.y"
	echo "src: $src, dst: $dst"
	echo
	"$stable_commits_check" --src "$src" --dest "$dst" --need_merge \
		--file mm/damon include/linux/damon.h
done
