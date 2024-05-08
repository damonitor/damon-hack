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
)

for (( i=0; i<$(( "${#versions[@]}" - 1 )); i++ ))
do
	from="${versions[$i]}"
	to="${versions[$((i + 1))]}-rc1"
	echo "$to"

	git log "$from..$to" --author sj@kernel.org --author sjpark@amazon.de | grep "Patch series"
done
