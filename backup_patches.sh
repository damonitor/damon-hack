#!/bin/bash

if [ $# -ne 2 ]
then
	echo "Usage: $0 <directory> <commits>"
	exit 1
fi

dest_dir=$1
commits=$2

mkdir -p "$dest_dir"
if [ -e "$dest_dir/series" ]
then
	rm -f "$dest_dir/series"
fi

for commit in $(git log --reverse --pretty=%H "$commits")
do
	if [ ! -e "$dest_dir/series" ]
	then
		baseline=$(git log --pretty=%H -1 "$commit^")
		echo "$baseline" > "$dest_dir/series"
	fi
	patch=$(git format-patch "$commit^".."$commit")
	final_name=$(echo "$patch" | cut -c 6-)
	mv "$patch" "$dest_dir/$final_name"
	echo "$final_name" >> "$dest_dir/series"
done
