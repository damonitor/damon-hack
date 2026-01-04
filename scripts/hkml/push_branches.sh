#!/bin/bash

# it is usual to add fixup commits of local commits that aimed to be squashed
# to the local commits before pushing.  But it is also usual forgetting the
# squashing.  Check it.
if git log --pretty="%s (%h)" korg/master..master | grep "^fixup "
then
	echo "seems the above fixup is not yet squashed"
	exit 1
fi

echo "ensure gpg password"
bindir=$(dirname "$0")
"$bindir/../ensure_gpg_password.sh"

for remote in gh.upstream gh.downstream korg
do
	echo "$remote"
	git push "$remote" master
done
