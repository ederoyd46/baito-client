#!/bin/bash
. cross-compile-environment.sh

BASE_PATH=`pwd`
uname=`uname`
LIB_SRC_PATH=$BASE_PATH/tmp
LIB_INSTALL_PATH=$BASE_PATH/lib
CURL_VERSION=7.28.1

COMMON_CONFIGURE_OPTS="--disable-shared --enable-static --with-darwinssl --without-ssl --without-libssh2 --without-librtmp --without-libidn --without-ca-bundle --enable-http --disable-rtsp --disable-ftp --disable-file --disable-ldap --disable-ldaps --disable-dict --disable-telnet --disable-tftp --disable-pop3 --disable-imap --disable-smtp --disable-gopher"

mkdir -p $LIB_SRC_PATH $LIB_INSTALL_PATH

cd $LIB_SRC_PATH
curl -C - -O http://curl.haxx.se/download/curl-$CURL_VERSION.tar.bz2
tar jxf curl-$CURL_VERSION.tar.bz2 

#Currently only set up to work on the Mac. Need to sort out the --with-darwinssl to use on another platform
if [ "$uname" == 'Darwin' ]; then
  cd curl-$CURL_VERSION
  ./configure --prefix=$LIB_INSTALL_PATH/host-libcurl $COMMON_CONFIGURE_OPTS
  make
  make install
  
  setenv_i386
  ./configure --prefix=$LIB_INSTALL_PATH/i386-libcurl --host=i386-apple-darwin $COMMON_CONFIGURE_OPTS
  make
  make install
  make clean

  setenv_arm7
  ./configure --prefix=$LIB_INSTALL_PATH/arm7-libcurl --host=armv7-apple-darwin $COMMON_CONFIGURE_OPTS
  make
  make install
  make clean
  
  setenv_arm7s
  ./configure --prefix=$LIB_INSTALL_PATH/arm7s-libcurl --host=armv7s-apple-darwin $COMMON_CONFIGURE_OPTS
  make
  make install
  make clean
  
  mkdir -p $LIB_INSTALL_PATH/common-libcurl/lib $LIB_INSTALL_PATH/common-libcurl/include
  cp -r $LIB_INSTALL_PATH/host-libcurl/include/* $LIB_INSTALL_PATH/common-libcurl/include
  lipo -create -output $LIB_INSTALL_PATH/common-libcurl/lib/libcurl.a $LIB_INSTALL_PATH/arm7s-libcurl/lib/libcurl.a \
    $LIB_INSTALL_PATH/arm7-libcurl/lib/libcurl.a $LIB_INSTALL_PATH/i386-libcurl/lib/libcurl.a $LIB_INSTALL_PATH/host-libcurl/lib/libcurl.a 
  
fi

cd $LIB_SRC_PATH
git clone https://github.com/ederoyd46/parson.git

