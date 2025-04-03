#!/bin/bash

damon_next_baseline="mm-new"

if [ $# -ne 1 ]
then
	echo "Usage: $0 <commit message>"
	echo
	echo "e.g., $0 \"rebase on latest $damon_next_baseline\""
	exit 1
fi

commit_msg=$1
bindir=$(dirname $0)
dest_dir=$(realpath "$bindir/../patches/next")
commits="akpm.korg.mm/$damon_next_baseline..damon/next"

commit_msg="$commit_msg

Assembled tree: $(git rev-parse damon/next)"

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

	# remove magic timestamp line to avoid unnecessary diff
	no_magic_tmp_patch=$(mktemp no_magic_timestamp_XXXX)
	tail -n +2 "$patch" > "$no_magic_tmp_patch"
	mv "$no_magic_tmp_patch" "$patch"

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
