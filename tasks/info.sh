#!/bin/sh

# Puppet Task Name: info
#

if [ -z "$PT_reponame" ]; then
  PT_reponame=`hostname -f`
fi

if [ -f /etc/borgbackup/repo_${PT_reponame}.sh ]; then
   . /etc/borgbackup/repo_${PT_reponame}.sh
   borg info
else
   echo "repository ${PT_reponame} not found"
fi
