#!/bin/bash
export BASE_PATH=`pwd`
export LIBSRC_PATH=$BASE_PATH/tmp
mkdir -p $LIBSRC_PATH
cd $LIBSRC_PATH
curl -C - -O http://curl.haxx.se/download/curl-7.28.1.tar.bz2
tar jxf curl-7.28.1.tar.bz2 
cd curl-7.28.1
./configure --prefix=$BASE_PATH/libcurl
make
make install
cd $LIBSRC_PATH
git clone https://github.com/kgabis/parson.git