#!/bin/bash
filename=$0
source_branch=$1
destination_branch=$2
pattern="^([A-Z]{2,}\d?-\d+|Merge|Revert|[Hh]otfix)"

# Arg checking
[ -z "$source_branch" ] && echo "Missing source branch" && exit 1
[ -z "$destination_branch" ] && echo "Missing destination branch" && exit 1

# Message comprehension
commit_messages=$(git log --pretty=format:%s $destination_branch..$source_branch)

exit_code=0
while read line ; do
	if echo "$line" | grep --invert-match --perl-regexp --quiet "$pattern"; then
		echo "--- ERROR -- Commit message does not match criteria: $line"
		# Defer termination to allow every line to spit out the message
		exit_code=1
	fi
done < <(echo "$commit_messages")

exit "$exit_code"
