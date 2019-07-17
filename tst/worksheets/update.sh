#!/bin/sh

# This script copies actual files over to the expected files;
# this is useful when adding new tests.

for actual in *.actual ; do
  expected="$(basename $actual .actual).expected"
  rm -rf $expected
  mkdir $expected
  cp $actual/*.xml $expected/
  mkdir $expected/tst
  cp $actual/tst/*.tst $expected/tst/
done
