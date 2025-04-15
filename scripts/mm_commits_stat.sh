#!/bin/bash

remote="akpm.korg.mm"
baseline=$(git describe --match "v*" --abbrev=0 akpm.korg.mm/mm-stable)

mm_stable_range="$baseline..$remote/mm-stable"
mm_unstable_range="$remote/mm-stable..$remote/mm-unstable"
mm_new_range="$remote/mm-unstable..$remote/mm-new"

nr_stable_patches=$(git rev-list --count "$mm_stable_range")
nr_unstable_patches=$(git rev-list --count "$mm_unstable_range")
nr_new_patches=$(git rev-list --count "$mm_new_range")

echo "mm-stable: $nr_stable_patches patches"
echo "$(git log --reverse "$mm_stable_range" | grep "Patch series")"
echo
echo "mm-unstable: $nr_unstable_patches patches"
echo "$(git log --reverse "$mm_unstable_range" | grep "Patch series")"
echo
echo "mm-new: $nr_new_patches patches"
echo "$(git log --reverse "$mm_new_range" | grep "Patch series")"
