#!/bin/sh
set -e -x

die() {
  echo "$1"
  exit 1
}

if [ -d bzr2git ]
then
    cd bzr2git
else
    git init bzr2git

    cd bzr2git

    git remote add 3.14 bzr::lp:~epics-core/epics-base/3.14
    git remote add 3.15 bzr::lp:~epics-core/epics-base/3.15
    git remote add 3.16 bzr::lp:~epics-core/epics-base/3.16
    git remote add github https://github.com/epics-base/epics-base.git
fi

git fetch 3.14
git fetch 3.15
git fetch 3.16

git push github 3.14/master:refs/heads/3.14 3.15/master:refs/heads/3.15 3.16/master:refs/heads/3.16
