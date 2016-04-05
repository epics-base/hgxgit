#!/bin/sh
set -e -x

die() {
  echo "$1"
  exit 1
}

srcdir="$PWD"

[ -d bzr2git ] || install -d bzr2git
cd bzr2git

lockfile -1 -r 5 lockfile || die "timeout waiting for lockfile"
trap "rm -f lockfile next.time" EXIT TERM INT

git remote|grep "^github$" || git remote add github https://github.com/epics-base/epics-base.git

topush=""

for branch in $(python "$srcdir/list-lp-branches.py" --since last.time next.time epics-base '^~epics-core/epics-base/')
do
    name="${branch#~epics-core/epics-base/}"
    echo "Sync branch $name"

    if ! git remote|grep "^${name}$$"
    then
      echo "Add remote lp-$name"
      git remote add "lp-$name" "bzr::lp:$branch"
    fi

    git fetch "lp-$name"

    topush="$topush +lp-${name}/master:refs/heads/${name}"
done

if [ "$topush" ]
then
  echo "Push $topush"
  # TODO: remove --dry-run
  git push --dry-run --tags github $topush
  mv next.time last.time
else
  echo "Nothing to push"
fi

echo "Done"
