#!/bin/bash
BASE_PATH=`pwd`
uname=`uname`
LIB_SRC_PATH=$BASE_PATH/tmp
LIB_INSTALL_PATH=$BASE_PATH/lib
CURL_VERSION=7.28.1


mkdir -p $LIB_SRC_PATH $LIB_INSTALL_PATH

cd $LIB_SRC_PATH
curl -C - -O http://curl.haxx.se/download/curl-$CURL_VERSION.tar.bz2
tar jxf curl-$CURL_VERSION.tar.bz2 

cd curl-$CURL_VERSION
./configure --prefix=$LIB_INSTALL_PATH/libcurl
make
make install

cd $LIB_SRC_PATH
git clone https://github.com/ederoyd46/parson.git

if [ "$uname" == 'Darwin' ]; then
  # Make sure a recent version of ruby is installed using 'brew install ruby' and modify the PATH to include it.
  git clone https://github.com/ederoyd46/curl-ios-build-scripts
  cd curl-ios-build-scripts
  ./build_curl --libcurl-version $CURL_VERSION 
  
  cd curl
  mkdir -p $LIB_INSTALL_PATH/ios-libcurl
  cp -r * $LIB_INSTALL_PATH/ios-libcurl
fi


