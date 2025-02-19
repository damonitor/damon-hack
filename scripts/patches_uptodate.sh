#!/bin/bash

bindir=$(dirname "$0")
assembled_tree=$(git -C "$bindir" log -1 --pretty=%b | \
	grep "^Assembled tree:" | awk '{print $3}')
linux_head="$(git rev-parse HEAD)"
if [ "$assembled_tree" = "$linux_head" ]
then
	echo "up to date"
	exit 0
fi

echo "not up to date"
exit 1
