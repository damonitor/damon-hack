#!/bin/bash

echo "ensure gpg password"
bindir=$(dirname "$0")
"$bindir/ensure_gpg_password.sh"

echo "push linux branches"

git fetch linus

echo "sj.korg"
git push sj.korg damon/next --force
git push sj.korg linus/master:master

echo "gh.public"
git push gh.public damon/next --force
git push gh.public linus/master:master

echo "gh.damon"
git push gh.damon damon/next:next --force
git push gh.damon linus/master:master

echo
echo "push damon-hack patches queue"

for r in $(git -C "$bindir" remote)
do
	echo "push damon-hack master to $r"
	git -C "$bindir" push "$r" master
done
