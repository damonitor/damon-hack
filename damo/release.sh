#!/bin/bash

if [ ! -x ./damo ]
then
	echo "This is supposed to be called from damo repo"
	exit 1
fi

first=$(./damo version | awk -F'.' '{print $1}')
second=$(./damo version | awk -F'.' '{print $2}')
third=$(./damo version | awk -F'.' '{print $3}')

current version is "$first.$second.$third"

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
read -p "ok? [y/N]" answer
if [ "$answer" -ne "y" ]
then
	exit 0
fi

echo "__version__ = '$new_version'" > damo_version.py
if [ $("./damo version") -ne "$new_version" ]
then
	echo "Making new version failed"
	exit 1
fi

git commit -as -m "Update the version"

bindir=$(dirname "$0")
"$bindir/../ensure_gpg_password.sh"
git tag -s -m "DAMO $new_version" "v$new_version"
for remote in downstream upstream korg
do
	git push "$remote" next next:master "v$new_version"
done

"./packaging/build.sh" "../damo.out" "v$new_version" --force
cd ../damo.out && python3 -m twine upload dist/*
