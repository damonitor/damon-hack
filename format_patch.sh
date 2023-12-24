#!/bin/bash

if [ $# -lt 3 ]
then
	echo "Usage: $0 <commit range> <subject-prefix> <output dir> [recipients file>]"
	exit 1
fi

commit_range=$1
subject_prefix=$2
outdir=$3
recipients_file=$4

if [ -f "$recipients_file" ]
then
	recipients=$(cat "$recipients_file")
fi

coverletter="$outdir/0000-cover-letter.patch"
if [ -f "$coverletter" ]
then
	cp "$coverletter" "$coverletter.old"
fi

baseline=$(git describe $(echo "$commit_range" | awk -F "." '{print $1}'))
git format-patch $recipients --cover-letter --base "$baseline" \
	--subject-prefix "$subject_prefix" -o "$outdir" $commit_range

echo
echo "# Patch files are ready at $outdir"
echo
echo "# Add recipients"
echo
# Assume this is called from linux directory
get_maintainer=./scripts/get_maintainer.pl
to_total="to_total"
cc_total="cc_total"
rm -f "$to_total"
rm -f "$cc_total"
for patch in "$outdir"/*.patch
do
	if [ "$(basename "$patch")" = "0000-cover-letter.patch" ]
	then
		continue
	fi

	to=$(sed 's/^/To: /' <<< \
		$("$get_maintainer" --nogit --nogit-fallback --norolestats --nol "$patch"))
	cc=$(sed 's/^/Cc: /' <<< \
		$("$get_maintainer" --nogit --nogit-fallback --norolestats --nom "$patch"))
	mv "$patch" "$patch.old"
	head -n 2 "$patch.old" > "$patch"
	echo "$to" >> "$patch"
	echo "$cc" >> "$patch"

	if echo "$patch" | grep --quiet "damon"
	then
		if ! cat "$patch" | grep "akpm@linux-foundation.org"
		then
			echo "To: Andrew Morton <akpm@linux-foundation.org>" >> "$patch"
			echo "To: Andrew Morton <akpm@linux-foundation.org>" >> "$to_total"
		fi
	fi

	if echo "$patch" | grep "damon" | grep "test" | grep --quiet "unit"
	then
		echo "Cc: Brendan Higgins <brendanhiggins@google.com>" >> "$patch"
		echo "Cc: David Gow <davidgow@google.com>" >> "$patch"
		echo "Cc: kunit-dev@googlegroups.com" >> "$patch"
		echo "Cc: linux-kselftest@vger.kernel.org" >> "$patch"

		echo "Cc: Brendan Higgins <brendanhiggins@google.com>" >> "$cc_total"
		echo "Cc: David Gow <davidgow@google.com>" >> "$cc_total"
		echo "Cc: kunit-dev@googlegroups.com" >> "$cc_total"
		echo "Cc: linux-kselftest@vger.kernel.org" >> "$cc_total"
	fi

	tail -n +3 "$patch.old" >> "$patch"
	rm "$patch.old"

	echo >> "$to_total"
	echo "$to" >> "$to_total"
	echo >> "$cc_total"
	echo "$cc" >> "$cc_total"
done

coverletter="$outdir"/0000-cover-letter.patch
coverletter_cp="$coverletter".cp
cp "$coverletter" "$coverletter_cp"
sort "$to_total" | uniq > "$coverletter"
sort "$cc_total" | uniq >> "$coverletter"
cat "$coverletter_cp" >> "$coverletter"
rm "$coverletter_cp"

echo "# Do checkpatch"

failed=()
for patch in "$outdir"/*.patch
do
	echo "$(basename "$patch")"
	result=$(./scripts/checkpatch.pl "$patch" | grep total)
	echo "    $result"
	errors=$(echo $result | awk '{print $2}')
	warnings=$(echo $result | awk '{print $4}')
	if [ "$errors" -gt 0 ] || [ "$warnings" -gt 0 ]
	then
		failed+=($patch)
	fi
done

echo
echo "Below patches contain warnings and/or errors"
for ((i = 0; i < ${#failed[@]}; i++))
do
	echo "$(basename ${failed[$i]})"
done
