#!/bin/bash
# Clone repos for basic DAMON hacks.

set -e

bindir=$(dirname "$0")

"$bindir/ensure_gpg_password.sh"

git clone git@github.com:sjp38/lazybox

git clone --origin gh git@github.com:damonitor/damo
git -C damo remote add korg git@gitolite.kernel.org:pub/scm/linux/kernel/git/sj/damo
git -C damo remote update

git clone --origin gh.upstream git@github.com:sjp38/hackermail
git -C hackermail remote add gh.downstream git@github.com:damonitor/hackermail
git -C hackermail remote add korg git@gitolite.kernel.org:pub/scm/linux/kernel/git/sj/hackermail
git -C hackermail remote update

git clone --origin gh git@github.com:damonitor/damon-tests
git -C damon-tests checkout gh/next -b next

git clone --origin gh.upstream git@github.com:sjp38/masim
git -C masim remote add gh.downstream git@github.com:damonitor/masim
git -C masim remote update

git clone --origin gh.damon git@github.com:damonitor/linux
git -C linux remote add gh.public git@github.com:sjp38/linux
git -C linux remote add sj.korg git@gitolite.kernel.org:pub/scm/linux/kernel/git/sj/linux
git -C linux remote add linus https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
git -C linux remote add akpm.korg.mm https://git.kernel.org/pub/scm/linux/kernel/git/akpm/mm.git
git -C linux remote add stable https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git
git -C linux remote update
git -C linux checkout sj.korg/damon/next -b damon/next

git -C "$bindir" remote add korg git@gitolite.kernel.org:pub/scm/linux/kernel/git/sj/damon-hack
git -C "$bindir" remote add gh git@github.com:damonitor/damon-hack
