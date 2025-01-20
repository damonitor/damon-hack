#!/bin/bash

echo "use hkml patch commit_cv instead"
exit 1

# Read damon_meta_changes/README for details.

if [ $# -ne 1 ]
then
	echo "Usage: $0 <meta change message>"
	exit 1
fi

msg=$1

mktemp damon_meta_changes/XXXXXXXX
git add damon_meta_changes
git commit -as -m "$msg"
