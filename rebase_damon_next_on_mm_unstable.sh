#!/bin/bash

set -e

if [ $# -gt 1 ]
then
	echo "Usage: $0 [old mm-unstable]"
	exit 1
fi

if [ $# -eq 1 ]
then
	old_mm_unstable=$1
else
	guess=$(git rev-parse akpm.korg.mm/mm-unstable)
	if git log damon/next --pretty=%H | grep "$guess" --max-count 1
	then
		old_mm_unstable=$guess
	else
		echo "Can't find the old mm-unstable.  Pass it explicitly"
		exit 1
	fi
fi

new_mm_unstable=akpm.korg.mm/mm-unstable

bindir=$(dirname "$0")

if ! "$bindir/ensure_gpg_password.sh"
then
	echo "ensure_gpg_password failed, as expected"
fi
git fetch akpm.korg.mm

old_mm_unstable_commit=$(git rev-parse "$old_mm_unstable")
new_mm_unstable_commit=$(git rev-parse "$new_mm_unstable")
if [ "$old_mm_unstable" = "$new_mm_unstable_commit" ]
then
	echo "No update on mm-unstable"
	exit 0
fi

new_mainline_base=$(git describe "$new_mm_unstable" --match "v*" --abbrev=0)

cp "$bindir/unmerged_commits.sh" ./
merged_commits=$(./unmerged_commits.sh --merged --human_readable \
	"$old_mm_unstable..damon/next" "$new_mainline_base..$new_mm_unstable")

git branch -M damon/next damon/next.old
git checkout akpm.korg.mm/mm-unstable -b damon/next.new
commits_to_pick=$(./unmerged_commits.sh "$old_mm_unstable..damon/next.old" \
	"$new_mainline_base..$new_mm_unstable")
if ! git cherry-pick --allow-empty $commits_to_pick
then
	echo "Cherry-pick failed."
	echo "Resolve it and do 'git branch -M damon/next.new damon/next'"
	exit 1
fi

git branch -M damon/next.new damon/next

echo "Below commits have merged"
echo "$merged_commits"
