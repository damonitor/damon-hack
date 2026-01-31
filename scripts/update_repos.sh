#!/bin/bash

set -e

bindir=$(dirname "$0")
"${bindir}/ensure_gpg_password.sh"

echo "damon-hack"
git -C "$bindir" remote update
git -C "$bindir" rebase korg/master

repos_dir="${bindir}/../../"

echo "damo"
git -C "${repos_dir}/damo" remote update
git -C "${repos_dir}/damo" rebase korg/next

echo "hackermail"
git -C "${repos_dir}/hackermail" remote update
git -C "${repos_dir}/hackermail" rebase korg/master

echo "damon-tests"
git -C "${repos_dir}/damon-tests" remote update
git -C "${repos_dir}/damon-tests" rebase gh/next

echo "masim"
git -C "${repos_dir}/masim" remote update
git -C "${repos_dir}/masim" rebase gh.upstream/master

echo "lazybox"
git -C "${repos_dir}/lazybox" remote update
git -C "${repos_dir}/lazybox" rebase origin/master

echo "linux"
# don't rebase linux as it might be complicated, and the tree can be reproduced
# from patches.
git -C "${repos_dir}/linux" remote update
