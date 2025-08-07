#!/bin/bash

echo "ensure gpg password"
bindir=$(dirname "$0")
"$bindir/ensure_gpg_password.sh"

echo "push linux branches"

git fetch linus

echo "sj.korg"
git push sj.korg damon/next --force
git push sj.korg linus/master:master
# git push sj.korg akpm.korg.mm/mm-new:refs/heads/mm-new --force
# git push sj.korg akpm.korg.mm/mm-stable:refs/heads/mm-unstable --force
# git push sj.korg akpm.korg.mm/mm-stable:refs/heads/mm-stable --force

echo "gh.public"
git push gh.public damon/next --force
git push gh.public linus/master:master
git push gh.public akpm.korg.mm/mm-new:refs/heds/mm-new --force
git push gh.public akpm.korg.mm/mm-stable:refs/heads/mm-unstable --force
git push gh.public akpm.korg.mm/mm-stable:refs/heads/mm-stable --force

echo "gh.damon"
git push gh.damon damon/next:next --force
git push gh.damon linus/master:master
git push gh.damon akpm.korg.mm/mm-new:refs/heads/mm-new --force
git push gh.damon akpm.korg.mm/mm-stable:refs/heads/mm-unstable --force
git push gh.damon akpm.korg.mm/mm-stable:refs/heads/mm-stable --force

echo
"$bindir/push_damon_hack.sh"
