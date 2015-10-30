#!/bin/sh
set -e -x

die() {
  echo "$1"
  exit 1
}

branch=${1:-"3.14"}
target=${2:-"epics-base-x"}

if [ -d bzr2git ]
then
    cd bzr2git
else
    git init bzr2git

    cd bzr2git

    git remote add ${branch} bzr::lp:~epics-core/epics-base/${branch}
    git remote add github git@github.com:epics-base/${target}.git
fi

git fetch ${branch}

git push --tags github +${branch}/master:refs/heads/${branch}
