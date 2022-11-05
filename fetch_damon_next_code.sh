#!/bin/bash

set -e

if [ $# -ne 1 ]
then
	echo "Usage: $0 <dir of the repo>"
	exit 1
fi

dir=$1

if [ ! -d "$dir" ]
then
	echo "$dir not exist.  Clone the repo."
	git clone git://git.kernel.org/pub/scm/linux/kernel/git/sj/linux.git \
		"$dir"
fi

damon_next="damon/next"
for damon_git_repo in "git.kernel.org/pub/scm/linux/kernel/git/sj/linux https \
	https://git.kernel.org/pub/scm/linux/kernel/git/sj/linux.git \
	https://kernel.googlesource.com/pub/scm/linux/kernel/git/sj/linux.git \
	https://github.com/damonitor/linux \
	git@github.com:damonitor/linux \
	https://github.com/sjp38/linux \
	git@github.com:sjp38/linux.git"
do
	git_remote=$(git -C "$dir" remote -v | \
		grep --max-count 1 "$damon_git_repo" | awk '{print $1}')
	if [ ! "$git_remote" = "" ]
	then
		if echo "$damon_git_repo" | grep -q "damonitor/linux"
		then
			damon_next="next"
		fi
		break
	fi
done

if [ "$git_remote" = "" ]
then
	"git remote not found in $dir"
	exit 1
fi

git -C "$dir" fetch "$git_remote"
git -C "$dir" checkout "${git_remote}/${damon_next}"
