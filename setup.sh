#!/bin/sh
set -e -x

die() {
  echo "$1" >&2
  exit 1
}

. "$PWD/config"

BASEDIR="$PWD"

[ -d repo ] || install -d repo

# setup new repositories
for RR in $REPOS
do
    cd "$BASEDIR"
    [ -d "repo/$RR" ] && continue

    git init "repo/$RR"
    cd "repo/$RR"

    git remote add github "$GITBASE/$RR.git"
    git remote add hg "hg::$HGBASE/$RR"
done

cd "$BASEDIR"

case "$1" in
 fetch*)
    REMOTE="${1#fetch}"
    for RR in $REPOS
    do
        cd "$BASEDIR/repo/$RR"
        git fetch "$REMOTE" || true
    done
   ;;
 pushgit)
    for RR in $REPOS
    do
        echo "Push $RR"
        cd "$BASEDIR/repo/$RR"
        branches=""
        for br in `git branch -r|grep '^\s*hg/branches/'`
        do
            barebr="${br#hg/branches/}"
            branches="$branches $br:refs/heads/$barebr"
        done
        echo "Branches: $branches"
        git push --tags github $branches || true
    done
   ;;

 *) die "Unknown command $1";;
esac
