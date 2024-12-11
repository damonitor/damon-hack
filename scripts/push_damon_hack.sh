#!/bin/bash

echo "ensure gpg password"
bindir=$(dirname "$0")
"$bindir/ensure_gpg_password.sh"

echo "push damon-hack patches queue"

for r in $(git -C "$bindir" remote)
do
	echo "push damon-hack master to $r"
	git -C "$bindir" push "$r" master
done
