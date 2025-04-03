#!/bin/bash

versions=(
	v5.14
	v5.15
	v5.16
	v5.17
	v5.18
	v5.19
	v6.0
	v6.1
	v6.2
	v6.3
	v6.4
	v6.5
	v6.6
	v6.7
	v6.8
	v6.9
	v6.10
	v6.11
	v6.12
	v6.13
	v6.14
	akpm.korg.mm/mm-stable
	akpm.korg.mm/mm-unstable
	akpm.korg.mm/mm-new
)

for (( i=0; i<$(( "${#versions[@]}" - 1 )); i++ ))
do
	from="${versions[$i]}"
	to="${versions[$((i + 1))]}-rc1"

	if [ "$to" = "akpm.korg.mm/mm-new-rc1" ]
	then
		from="akpm.korg.mm/mm-unstable"
		to="akpm.korg.mm/mm-new"
	fi

	if [ "$to" = "akpm.korg.mm/mm-unstable-rc1" ]
	then
		from="akpm.korg.mm/mm-stable"
		to="akpm.korg.mm/mm-unstable"
	fi

	if [ "$to" = "akpm.korg.mm/mm-stable-rc1" ]
	then
		from+="-rc1"
		to="akpm.korg.mm/mm-stable"
	fi

	echo "$to"
	git log "$from..$to" --author sj@kernel.org --author sjpark@amazon.de | grep "Patch series"
done
