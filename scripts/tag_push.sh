#!/bin/bash

set -e

# Tag damon-hack with date and baseline, and push

echo "ensure gpg password"
bindir=$(dirname "$0")
if ! "$bindir/ensure_gpg_password.sh"
then
	echo "ensure_gpg_password failed as expected"
fi

datetime=$(date +"%Y-%m-%d-%H-%M")
baseline=$(git describe --match "v*" --abbrev=0)
tagname=damon/next-$datetime-on-$baseline
echo "tagging as $tagname"
git -C "$bindir" tag -as "$tagname" -m "$tagname"

echo "push"
echo "gh"
git -C "$bindir" push gh "$tagname"
echo "korg"
git -C "$bindir" push korg "$tagname"
