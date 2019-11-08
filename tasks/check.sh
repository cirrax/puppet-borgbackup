#!/bin/sh

# Puppet Task Name: check
#

if [ -z "$PT_reponame" ]; then
  PT_reponame=`hostname -f`
fi

if [ -f /etc/borgbackup/repo_${PT_reponame}.sh ]; then
   /etc/borgbackup/repo_${PT_reponame}.sh check 2>&1 |sed -n '/^Analyzing/,$p'
else
   echo "repository ${PT_reponame} not found"
fi
