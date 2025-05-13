#!/bin/bash

pr_usage()
{
	echo "
Usage: $0 [OPTION] <dev commits> <maintainer tree commits>

OPTION
  --human_readable	Print in human readable manner
  --merged		Print merged commits
"
}

pr_usage_exit()
{
	exit_msg=$1
	exit_code=$2
	echo "$exit_msg"
	echo
	pr_usage
	exit "$exit_code"
}

human_readable="false"
pr_merged="false"

while [ $# -ne 0 ]
do
	case $1 in
	"--human_readable")
		human_readable="true"
		shift 1
		continue
		;;
	"--merged")
		pr_merged="true"
		shift 1
		continue
		;;
	*)
		if [ $# -ne 2 ]
		then
			pr_usage_exit "wrong number of arguments" 1
		fi
		dev_commits_range=$1
		maintainer_commits_range=$2
		shift 2
		;;
	esac
done

if [ "$dev_commits_range" = "" ]
then
	pr_usage_exit "" 1
fi

dev_commits=$(git log "$dev_commits_range" --pretty=%H --reverse)
maintainer_commits=$(git log "$maintainer_commits_range" --pretty=%H --reverse)
maintainer_subjects=$(git log "$maintainer_commits_range" --pretty=%s --reverse)

for dev_commit in $dev_commits
do
	dev_subject=$(git show "$dev_commit" --pretty=%s --quiet)

	# todo: handle escaping characters, e.g., [ and ]
	if echo "$maintainer_subjects" | grep "$dev_subject" --quiet --ignore-case
	then
		merged="true"
	else
		merged="false"
	fi

	if [ ! "$merged" = "$pr_merged" ]
	then
		continue
	fi

	if [ "$human_readable" = "true" ]
	then
		echo "$dev_commit ($dev_subject)"
	else
		echo "$dev_commit"
	fi
done
