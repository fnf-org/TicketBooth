#!/bin/bash

# ANSI color codes
BOLD_YELLOW='\033[1;33m'
BOLD_RED='\033[1;31m'
RESET='\033[0m'

while true; do
	if [[ -z "$*" ]]; then
		# Prompt user (to STDERR)
		echo -n "Please name the branch for your changes: " >&2

		# Print bold yellow escape sequence
		echo -ne "${BOLD_YELLOW}" >&2

		# Read user input
		read branch_input
	else
		branch_input="$*"
	fi

	# Reset color
	echo -ne "${RESET}" >&2

	# Transform the input:
	# 1. Replace non-alphanumeric (except / and space) with dash
	# 2. Replace sequences of multiple dashes with single dash
	# 3. Convert to lowercase
	branch_name="$(echo "${branch_input}" |
		sed -E 's/[^a-zA-Z0-9/-]/-/g' |
		sed -E 's/-+/-/g; ' |
		tr '[:upper:]' '[:lower:]')"

	# Prepend $USER/ if not already present
	if [[ ! "$branch_name" =~ ^${USER}/ ]]; then
		branch_name="${USER}/${branch_name}"
	fi

	# Check length
	if [ ${#branch_name} -gt 50 ]; then
		echo -e "${BOLD_RED}Error: Branch name is too long (${#branch_name} characters, max 50)${RESET}" >&2
		echo >&2
		continue
	fi

	# Output the branch name to STDOUT
	echo "${branch_name}"
	break
done
