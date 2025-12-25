#!/bin/bash

set -e

if [ $# -gt 1 ]
then
	echo "Usage: $0 [old mm-new]"
	exit 1
fi

if [ ! "$(git rev-parse --abbrev-ref HEAD)" = "damon/next" ]
then
	echo "You should be on damon/next"
	exit 1
fi

bindir=$(dirname "$0")
if ! "$bindir/patches_uptodate.sh"
then
	echo "Patches queue is not up to date."
	exit 1
fi

if [ $# -eq 1 ]
then
	old_mm_new=$1
else
	for commit in $(git log -n 300 --pretty=%h)
	do
		if [ "$(git log -1 "$commit" --pretty=%s)" = \
			"=== mark start of DAMON hack tree ===" ]
		then
			old_mm_new="$(git rev-parse "$commit"^)"
			break
		fi
	done

	if [ "$old_mm_new" = "" ]
	then
		echo "Can't find the old mm-new.  Pass it explicitly"
		exit 1
	fi
	echo "old mm-new found as $old_mm_new"
fi

new_mm_new=akpm.korg.mm/mm-new

git fetch akpm.korg.mm

old_mm_new_commit=$(git rev-parse "$old_mm_new")
new_mm_new_commit=$(git rev-parse "$new_mm_new")
if [ "$old_mm_new" = "$new_mm_new_commit" ]
then
	echo "No update on mm-new"
	exit 0
fi

new_mainline_base=$(git describe "$new_mm_new" --match "v*" --abbrev=0)

unmerged_commits_sh="$bindir/unmerged_commits.sh"
merged_commits=$("$unmerged_commits_sh" --merged --human_readable \
	"$old_mm_new..damon/next" "$new_mainline_base..$new_mm_new")

git branch -M damon/next damon/next.old
git checkout akpm.korg.mm/mm-new -b damon/next.new

version_marking_commit=""
old_mainline_base=$(git describe "$old_mm_new" --match "v*" --abbrev=0)
for commit in $("$unmerged_commits_sh" "$old_mm_new..damon/next.old" \
	"$new_mainline_base..$new_mm_new")
do
	if [ "$(git log -1 "$commit" --pretty=%s)" = \
		"add -damon suffix to the version name" ]
	then
		is_damon_version_marking_commit="true"
	else
		is_damon_version_marking_commit="false"
	fi

	if [ ! "$old_mainline_base" = "$new_mainline_base" ] && \
		[ "$is_damon_version_marking_commit" = "true" ]
	then
		version_marking_commit="$commit"
		continue
	fi

	if ! git cherry-pick --allow-empty "$commit"
	then
		echo "Cherry-pick failed for $commit."
		echo "What do do?"
		echo "1. Skip it and continue."
		echo "2. Wait until you manually resolve it in another window."
		echo "3. Just exit."
		read -p "Enter the item number: " answer
		if [ "$answer" = "1" ]
		then
			git cherry-pick --skip
			continue
		fi
		if [ "$answer" = "2" ]
		then
			read -p "Enter anything after manual resolving: " foo
			continue
		fi

		echo "Ok, aborting here.  Resolve it, further apply"
		echo $("$unmerged_commits_sh" \
			"$old_mm_new..damon/next.old" \
			"$new_mainline_base..$new_mm_new")
		echo "and do 'git branch -M damon/next.new damon/next'"
		exit 1
	fi
done

git branch -M damon/next.new damon/next

if [ ! "$old_mainline_base" = "$new_mainline_base" ]
then
	echo
	echo "!!! Pick the DAMON version commit manually"
	echo "!!! ($version_marking_commit)"
	echo
fi

echo
echo "Below commits have merged"
echo "$merged_commits"
echo
