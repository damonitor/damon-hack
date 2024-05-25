#!/bin/bash

echo "ensure gpg password"
bindir=$(dirname "$0")
"$bindir/../ensure_gpg_password.sh"

for remote in upstream downstream korg
do
	echo "$remote"
	git push "$remote" next
done
