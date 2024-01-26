#!/bin/bash

if [ $# -ne 2 ]
then
	echo "Usage: $0 <remote> <baseline>"
	exit 1
fi

remote=$1
baseline=$2

mm_stable_range="$baseline..$remote/mm-stable"
mm_unstable_range="$remote/mm-stable..$remote/mm-unstable"

nr_stable_patches=$(git rev-list --count "$mm_stable_range")
nr_unstable_patches=$(git rev-list --count "$mm_unstable_range")

echo "mm-stable: $nr_stable_patches patches"
echo "$(git log "$mm_stable_range" | grep "Patch series")"
echo
echo "mm-unstable: $nr_unstable_patches patches"
echo "$(git log "$mm_unstable_range" | grep "Patch series")"
