#!/bin/bash
filename=$0
expected_check=$3

# Compute checksum
this_file_check="$(shasum -a 512 $filename | cut -d " " -f 1 )"
if [[ "$this_file_check" != "$expected_check" ]]; then
	echo "---DANGER --- Checksums do not match!"
	echo "Expected $expected_check got $this_file_check"
	exit 1
fi

source_branch=$1
destination_branch=$2
pattern="^(([A-Z]{2,}\d?-\d+)|hotfix)"

# Arg checking
[ -z "$source_branch" ] && echo "Missing source branch" && exit 1
[ -z "$destination_branch" ] && echo "Missing destination branch" && exit 1

# Message comprehension
commit_messages=$(git log --pretty=format:%s $destination_branch..$source_branch)

exit_code=0
echo "$commit_messages" | while read line ; do
	if echo "$line" | grep -v -q -E "$pattern"; then
		echo "--- ERROR -- Commit message does not match criteria: $line"
		# Defer termination to allow every line to spit out the message
		exit_code=1
	fi
done

exit $exit_code
