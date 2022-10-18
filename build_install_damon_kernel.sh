#!/bin/bash

if [ $# -ne 1 ]
then
	echo "Uage: $0 <build dir>"
	exit 1
fi

outdir=$1

bindir=$(dirname "$0")

"$bindir/build_damon_kernel.sh" "$outdir"
sudo make O="$outdir" modules_install install
