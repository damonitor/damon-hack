#!/bin/bash

set -e

if [ ! -x ./hkml ]
then
	echo "This is supposed to be called from hkml repo"
	exit 1
fi

current_version=$(git tag | sort -V | tail -n 1)

first=$(echo "$current_version" | awk -F'[v.]' '{print $2}')
second=$(echo "$current_version" | awk -F'[v.]' '{print $3}')
third=$(echo "$current_version" | awk -F'[v.]' '{print $4}')

echo "current version is $first.$second.$third"

if [ "$third" -ne 9 ]
then
	third=$((third + 1))
else
	third=0
	if [ "$second" -ne 9 ]
	then
		second=$((second + 1))
	else
		second=0
		first=$((first + 1))
	fi
fi

new_version="$first.$second.$third"

echo "will mark as $new_version and release"
read -p "ok? [y/N] " answer
if [ ! "$answer" = "y" ]
then
	exit 0
fi

bindir=$(dirname "$0")
if !  "$bindir/../ensure_gpg_password.sh"
then
	echo "ensuring gpg password failed, as expected"
fi
git tag -s -m "Hackermail $new_version" "v$new_version" 
for remote in gh.downstream gh.upstream korg
do
	git push "$remote" master "v$new_version"
done
