#!/bin/bash

bindir=$(dirname "$0")
assembled_tree=$(git -C "$bindir" log -42 --pretty=%b | \
	grep "^Assembled tree:" | head -n 1 | awk '{print $3}')
linux_head="$(git rev-parse HEAD)"
if [ "$assembled_tree" = "$linux_head" ]
then
	echo "up to date"
	exit 0
fi

echo "not up to date"
exit 1
