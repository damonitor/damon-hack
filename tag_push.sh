#!/bin/bash

echo "ensure gpg password"
bindir=$(dirname "$0")
"$bindir/ensure_gpg_password.sh"

datetime=$(date +"%Y-%m-%d-%H-%M")
baseline=$(git describe --match "v*" --abbrev=0)
tagname=damon/next-$datetime-on-$baseline
echo "tagging as $tagname"
git tag -as "$tagname" -m "A snapshot of damon/next"
echo "push"
"$bindir/_push_tag.sh" "$tagname"
