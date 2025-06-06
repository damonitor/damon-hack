#!/bin/bash

bindir=$(dirname "$0")
baseline=$("$bindir/get_damon_next_baseline_commit.sh")
if [ "$baseline" = "" ]
then
	echo "failed baseline finding"
	exit 1
fi
git rebase -i "$baseline"
