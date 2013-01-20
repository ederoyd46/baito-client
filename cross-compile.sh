#!/bin/bash
. cross-compile-environment.sh

BASE_PATH=`pwd`
uname=`uname`

make clean
make

if [ "$uname" == 'Darwin' ]; then
  setenv_arm7
  make CROSS_COMPILE=arm7

  setenv_arm7s
  make CROSS_COMPILE=arm7s

  setenv_i386
  make CROSS_COMPILE=i386
fi