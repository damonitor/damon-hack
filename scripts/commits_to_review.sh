#!/bin/bash

if [ $# -ne 1 ]
then
	echo "Usage: $0 <commits>"
	exit 1
fi

commits=$1

review_missed=""

for commit in $(git log --reverse "$commits" --pretty=%H)
do
	commit_content=$(git show "$commit")
	if ! echo "$commit_content" | grep damon --quiet
	then
		continue
	fi
	if echo "$commit_content" | grep "Signed-off-by: SeongJae Park" --quiet
	then
		continue
	fi
	if ! git show "$commit" | grep "Reviewed-by: SeongJae Park" --quiet
	then
		review_missed+="$commit "
	fi
done

for commit in $review_missed
do
	desc=$(git log -1 "$commit" --pretty="%h (\"%s\")")
	echo "review missed for $desc"
done
