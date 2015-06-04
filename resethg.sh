#!/bin/sh
set -e

die() {
  echo "$1" >&2
  exit 1
}

[ -d .git/hg ] || die "Not a repo using git-remote-hg"

git update-ref -d notes/hg
git update-ref -d refs/notes/hg

rm -rf .git/hg

git fetch hg
