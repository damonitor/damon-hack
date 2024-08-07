#!/bin/bash

if [ $# -ne 1 ]
then
	echo "Usage: $0 <commit message>"
	echo
	echo "e.g., $0 \"rebase on latest mm-unstable\""
	exit 1
fi

commit_msg=$1
bindir=$(dirname $0)
dest_dir=$(realpath "$bindir/../patches/next")
commits="akpm.korg.mm/mm-unstable..damon/next"

git -C "$bindir" rm -r "$dest_dir"
mkdir -p "$dest_dir"

for commit in $(git log --reverse --pretty=%H "$commits")
do
	if [ ! -e "$dest_dir/series" ]
	then
		baseline=$(git log --pretty=%H -1 "$commit^")
		echo "$baseline" > "$dest_dir/series"
	fi
	patch=$(git format-patch "$commit^".."$commit")
	final_name=$(echo "$patch" | cut -c 6-)
	nr_duplicates=0
	while [ -e "$dest_dir/$final_name" ]
	do
		nr_duplicates=$((nr_duplicates + 1))
		final_name+="-$nr_duplicates"
	done
	mv "$patch" "$dest_dir/$final_name"
	echo "$final_name" >> "$dest_dir/series"
done

git -C "$bindir" add "$dest_dir"
git -C "$bindir" commit -s -m "patches/next: $commit_msg"
