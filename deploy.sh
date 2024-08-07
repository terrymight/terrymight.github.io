#!/bin/sh

# If a command fails then deploy stops

set -e

printf "\033[0;32mDeploying updates to GitHub...\033[0m\n"

# Build the project. 
hugo -D # if using a theme, replace with `hugo -t <YOURTHEME>`


# Add changes to git.
git add .

# Commit changes.
msg="rebuilding site by $(whoami) $(date)"
if [ -n "$*" ]; then
	msg="$*"
fi
git commit -m "$msg"

# Push source and build repos.
git push origin main