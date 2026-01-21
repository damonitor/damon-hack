#!/bin/bash

set -e

bindir=$(dirname "$0")
"$bindir/ensure_gpg_password.sh"
"$bindir/backup_patches.sh" "$@"
"$bindir/push_branches.sh"
