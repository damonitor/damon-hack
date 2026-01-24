#!/bin/bash

bindir=$(dirname "$0")
review_stat_py="${bindir}/../../lazybox/linux_hack/review_stat.py"
if [ ! -f "$review_stat_py" ]
then
	echo "${review_stat_py} not found"
	exit 1
fi

sj="SeongJae Park <sj@kernel.org>"

"$review_stat_py" --commits sj.korg/mm-stable..sj.korg/mm-new \
	--subsystem DAMON --not_signed_off_by "$sj" --not_reviewed_by "$sj" \
	--not_acked_by "$sj"
