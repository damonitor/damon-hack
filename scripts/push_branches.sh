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

echo "damon"

extra_version=$(git show refs/heads/damon/for-next:Makefile | \
	grep "EXTRAVERSION = " | awk '{print $3}' | awk -F"-rc" '{print $2}'
# Starting from rc6, avoid force-push
if [ "$extra_version" -gt 5 ]
then
	force_push="false"
else
	force_push="true"
fi

if [ "$force_push" = "true" ]
then
	git push damon refs/heads/damon/for-next:for-next --force
	git push damon refs/heads/damon/for-next-fixes:for-next-fixes --force
else
	git push damon refs/heads/damon/for-next:for-next
	git push damon refs/heads/damon/for-next-fixes:for-next-fixes
fi

echo
"$bindir/push_damon_hack.sh"
