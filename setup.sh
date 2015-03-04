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
        git fetch "$REMOTE"
    done
   ;;
 pushgit)
    for RR in $REPOS
    do
        cd "$BASEDIR/repo/$RR"
        git branch -r|grep '^\s*hg/branches/' | while read br
        do
            barebr="${br#hg/branches/}"
            git push --tags github $br:refs/heads/$barebr
        done
    done
   ;;

 *) die "Unknown command $1";; 
esac
