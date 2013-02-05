#!/bin/bash
. cross-compile-environment.sh

BASE_PATH=`pwd`
uname=`uname`

make clean
make

if [ "$uname" == 'Darwin' ]; then
  setenv_arm7
  make CROSS_COMPILE=armv7

  setenv_arm7s
  make CROSS_COMPILE=armv7s
  
  setenv_i386
  make CROSS_COMPILE=i386
  
  BUILD=./build
  COMMON_LIB_LIB=$BUILD/common-libbaito/lib
  COMMON_INCLUDE=$BUILD/common-libbaito/include
  
  mkdir -p $COMMON_LIB_LIB $COMMON_INCLUDE
  cp -r $BUILD/libbaito/include/* $COMMON_INCLUDE
  
  lipo -create -output $COMMON_LIB_LIB/libbaito.a $BUILD/armv7s-libbaito/lib/libbaito.a \
    $BUILD/armv7-libbaito/lib/libbaito.a $BUILD/i386-libbaito/lib/libbaito.a $BUILD/libbaito/lib/libbaito.a

fi