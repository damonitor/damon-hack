#!/bin/bash

echo "ensure gpg password"
bindir=$(dirname "$0")
"$bindir/ensure_gpg_password.sh"

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
