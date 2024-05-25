#!/bin/bash

set -e

if [ $# -ne 1 ]
then
	echo "Usage: $0 <build dir>"
	exit 1
fi

outdir=$1

bindir=$(dirname "$0")

"$bindir/build_install_damon_kernel.sh" "$outdir"

echo "build and install completed.  reboot now"
sudo shutdown -r now
