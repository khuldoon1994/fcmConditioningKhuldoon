#!/bin/bash

# See this post for mor information:
# https://stackoverflow.com/questions/7726949/remove-local-branches-no-longer-on-remote

# SHow local branches, which are no longer on the remote
echo "The following branches will be deleted:"
git fetch -p && git branch -vv | awk '/: gone]/{print $1}'

read -p "Are you sure? " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]
then
# Delete these branches
git fetch -p && git branch -vv | awk '/: gone]/{print $1}' | xargs git branch -d
fi

