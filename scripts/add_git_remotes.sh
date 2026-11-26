#!/bin/bash

# <repo name>.<account name>.<hosting site>
#
# <repo name> is omitted if it is linux.
# <hosting site> is omitted if it is kernel.org

git remote add damon.gh	git@github.com:damonitor/linux.git
git remote add sj.gh git@github.com:sjp38/linux.git
git remote add linus   git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
git remote add sj git@gitolite.kernel.org:pub/scm/linux/kernel/git/sj/linux
git remote add stable  git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git
git remote add mm.akpm git://git.kernel.org/pub/scm/linux/kernel/git/akpm/mm
git remote add damon git@gitolite.kernel.org:pub/scm/linux/kernel/git/mm/damon
git remote add mm git://git.kernel.org/pub/scm/linux/kernel/git/mm/linux.git
