#!/bin/bash

# Find commits for stable kernel trees that not merged in appropriate trees
# yet.

bindir=$(dirname "$0")
lbx_path=$(realpath "$bindir/../lazybox")

if [ ! -d "$lbx_path" ]
then
	echo "lazybox not found at $lbx_path"
	exit 1
fi

for tree in 5.15 6.1 6.6 6.8
do
	src="v$tree..linus/master"
	dst="v$tree..stable/linux-$tree.y"
	echo "src: $src, dst: $dst"
	echo
	"$lbx_path/linux_hack/stable_commits_check.py" \
		--src "$src" --dest "$dst" \
		--file mm/damon include/linux/damon.h --need_merge
done
