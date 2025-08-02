#!/bin/bash

echo "ensure gpg password"
bindir=$(dirname "$0")
"$bindir/ensure_gpg_password.sh"

echo "push linux branches"

git fetch linus

echo "sj.korg"
git push sj.korg damon/next --force
git push sj.korg linus/master:master
git push sj.korg akpm.korg.mm/mm-new:refs/heads/mm-new
git push sj.korg akpm.korg.mm/mm-stable:refs/heads/mm-unstable
git push sj.korg akpm.korg.mm/mm-stable:refs/heads/mm-stable

echo "gh.public"
git push gh.public damon/next --force
git push gh.public linus/master:master
git push gh.public akpm.korg.mm/mm-new:refs/heds/mm-new
git push gh.public akpm.korg.mm/mm-stable:refs/heads/mm-unstable
git push gh.public akpm.korg.mm/mm-stable:refs/heads/mm-stable

echo "gh.damon"
git push gh.damon damon/next:next --force
git push gh.damon linus/master:master
git push gh.damon akpm.korg.mm/mm-new:refs/heads/mm-new
git push gh.damon akpm.korg.mm/mm-stable:refs/heads/mm-unstable
git push gh.damon akpm.korg.mm/mm-stable:refs/heads/mm-stable

echo
"$bindir/push_damon_hack.sh"
