#!/bin/bash

set -e

if [ $# -gt 1 ]
then
	echo "Usage: $0 [old mm-unstable]"
	exit 1
fi

if [ ! "$(git rev-parse --abbrev-ref HEAD)" = "damon/next" ]
then
	echo "You should be on damon/next"
	exit 1
fi

if [ $# -eq 1 ]
then
	old_mm_unstable=$1
else
	for commit in $(git log -n 300 --pretty=%h)
	do
		if [ "$(git log -1 "$commit" --pretty=%s)" = \
			"=== mark start of DAMON hack tree ===" ]
		then
			old_mm_unstable="$(git rev-parse "$commit"^)"
			break
		fi
	done

	if [ "$old_mm_unstable" = "" ]
	then
		echo "Can't find the old mm-unstable.  Pass it explicitly"
		exit 1
	fi
	echo "old mm-unstable found as $old_mm_unstable"
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

version_marking_commit=""
old_mainline_base=$(git describe "$old_mm_unstable" --match "v*" --abbrev=0)
for commit in $(./unmerged_commits.sh "$old_mm_unstable..damon/next.old" \
	"$new_mainline_base..$new_mm_unstable")
do
	if [ "$(git log -1 "$commit" --pretty=%s)" = \
		"Add -damon suffix to the version name" ]
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
		echo "Resolve it, further apply"
		echo $(./unmerged_commits.sh \
			"$old_mm_unstable..damon/next.old" \
			"$new_mainline_base..$new_mm_unstable")
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
