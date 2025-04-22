#!/bin/bash

set -e

if [ ! -x ./damo ]
then
	echo "This is supposed to be called from damo repo"
	exit 1
fi

first=$(./damo version | awk -F'.' '{print $1}')
second=$(./damo version | awk -F'.' '{print $2}')
third=$(./damo version | awk -F'.' '{print $3}')

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

# damo_version.py has moved from root to src/ after v2.3.4.  Support <=2.3.4
# versions.
damo_version_py="src/damo_version.py"
if [ ! -e "$damo_version_py" ]
then
	damo_version_py=damo_version.py
fi
echo "__version__ = '$new_version'" > "$damo_version_py"
if [ ! $(./damo version) = "$new_version" ]
then
	echo "Making new version failed"
	exit 1
fi

git add "$damo_version_py"
git commit -s -m "Update the version"

bindir=$(dirname "$0")
if ! "$bindir/../ensure_gpg_password.sh"
then
	echo "ensuring gpg password failed, as expected"
fi
git tag -s -m "DAMO $new_version" "v$new_version"
for remote in gh korg
do
	git push "$remote" next next:master "v$new_version"
done

"./packaging/build.sh" "../damo.out" "v$new_version" --force
cd ../damo.out && python3 -m twine upload dist/*
