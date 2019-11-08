#!/bin/sh

# Puppet Task Name: list
#


if [ -z "$PT_reponame" ]; then
  PT_reponame=`hostname -f`
fi

if [ -f /etc/borgbackup/repo_${PT_reponame}.sh ]; then
   /etc/borgbackup/repo_${PT_reponame}.sh list
else
   echo "repository ${PT_reponame} not found"
fi

