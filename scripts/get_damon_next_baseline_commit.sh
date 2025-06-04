#!/bin/bash

for commit in $(git log -n 500 --pretty=%h)
do
	if [ "$(git log -1 "$commit" --pretty=%s)" = \
		"=== mark start of DAMON hack tree ===" ]
	then
		echo "$(git rev-parse "$commit"^)"
		exit 0
	fi
done
exit 1
