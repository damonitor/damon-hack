#!/bin/bash

set -e

bindir=$(dirname "$0")
"$bindir/backup_patches.sh" "$@"
"$bindir/push_branches.sh"
