#!/bin/bash
set -x
set -e

usage () {
  echo 'Usage : $0 [vendor.conf]'
  exit
}

if [ -z $1 ]; then
  usage
fi

conf=$1

cat $1 | while IFS= read -r line
do
  repo=`echo $line | cut -d " " -f 1`
  ver=`echo $line | cut -d " " -f 2`
  echo swithing $repo to $ver
  if [ ! -d $GOPATH/src/$repo ]; then
    go get $repo/...
  fi
  cd $GOPATH/src/$repo
  git checkout master
  git pull
  git checkout $ver
done
