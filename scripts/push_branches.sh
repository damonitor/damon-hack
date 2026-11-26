#!/bin/bash

echo "ensure gpg password"
bindir=$(dirname "$0")
"$bindir/ensure_gpg_password.sh"

echo "push linux branches"

git fetch linus

echo "sj"
git push sj damon/next --force
git push sj linus/master:master
git push sj mm.akpm/mm-new:refs/heads/mm-new --force
git push sj mm.akpm/mm-unstable:refs/heads/mm-unstable --force
git push sj mm.akpm/mm-stable:refs/heads/mm-stable --force

echo "sj.gh"
git push sj.gh damon/next --force
git push sj.gh linus/master:master
git push sj.gh mm.akpm/mm-new:refs/heds/mm-new --force
git push sj.gh mm.akpm/mm-unstable:refs/heads/mm-unstable --force
git push sj.gh mm.akpm/mm-stable:refs/heads/mm-stable --force

echo "damon.gh"
git push damon.gh damon/next:next --force
git push damon.gh linus/master:master
git push damon.gh mm.akpm/mm-new:refs/heads/mm-new --force
git push damon.gh mm.akpm/mm-unstable:refs/heads/mm-unstable --force
git push damon.gh mm.akpm/mm-stable:refs/heads/mm-stable --force

echo
"$bindir/push_damon_hack.sh"
