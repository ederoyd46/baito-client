#!/bin/bash
. cross-compile-environment.sh

BASE_PATH=`pwd`
uname=`uname`
LIB_SRC_PATH=$BASE_PATH/tmp
LIB_INSTALL_PATH=$BASE_PATH/lib

mkdir -p $LIB_SRC_PATH $LIB_INSTALL_PATH

if [ "$uname" == 'Darwin' ]; then
  SSL_VERSION=1.0.1c
  cd $LIB_SRC_PATH
  curl -C - -O http://www.openssl.org/source/openssl-$SSL_VERSION.tar.gz
  tar zxf openssl-$SSL_VERSION.tar.gz
  cd openssl-$SSL_VERSION

  ./Configure darwin64-x86_64-cc --prefix=$LIB_INSTALL_PATH/host-libssl &> /tmp/build-platform-configure-openssl-host.log
  make &> /tmp/build-platform-build-openssl-host.log
  make install &> /tmp/build-platform-install-openssl-host.log

  build_openssl() {
    COMPILER=$1
    ARCH=$2
    IOS_SDK_ROOT=$3
    
    echo ARCH $ARCH
    echo COMPILER $COMPILER
    echo IOS_SDK_ROOT $IOS_SDK_ROOT
    
    cd $LIB_SRC_PATH
    rm -rf openssl-$SSL_VERSION
    tar zxf openssl-$SSL_VERSION.tar.gz
    cd openssl-$SSL_VERSION
    
    ./Configure BSD-generic32 --prefix=$LIB_INSTALL_PATH/$ARCH-libssl &>/tmp/build-platform-configure-openssl-$ARCH.log
    perl -i -pe 's|static volatile sig_atomic_t intr_signal|static volatile int intr_signal|' crypto/ui/ui_openssl.c
    perl -i -pe "s|^CC= gcc|CC= ${COMPILER} -arch ${ARCH}|g" Makefile
    perl -i -pe "s|^CFLAG= (.*)|CFLAG= -isysroot ${IOS_SDK_ROOT} \$1|g" Makefile
    make &> /tmp/build-platform-build-openssl-$ARCH.log
    make install &> /tmp/build-platform-install-openssl-$ARCH.log
  }

  IPHONE_OS_GCC="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/gcc"
  IPHONE_OS_SDK="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS6.1.sdk"
  IPHONE_SIM_GCC="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/usr/bin/gcc"
  IPHONE_SIM_SDK="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator6.1.sdk"

  build_openssl $IPHONE_OS_GCC "armv7" $IPHONE_OS_SDK
  build_openssl $IPHONE_OS_GCC "armv7s" $IPHONE_OS_SDK
  build_openssl $IPHONE_SIM_GCC "i386" $IPHONE_SIM_SDK
fi




#Currently only set up to work on the Mac. Need to sort out the --with-darwinssl to use on another platform
if [ "$uname" == 'Darwin' ]; then
  CURL_VERSION=7.28.1
  COMMON_CURL_CONFIGURE_OPTS="--disable-shared --enable-static --with-darwinssl --without-ssl --without-libssh2 --without-librtmp --without-libidn --without-ca-bundle --enable-http --disable-rtsp --disable-ftp --disable-file --disable-ldap --disable-ldaps --disable-dict --disable-telnet --disable-tftp --disable-pop3 --disable-imap --disable-smtp --disable-gopher"
  
  cd $LIB_SRC_PATH

  curl -C - -O http://curl.haxx.se/download/curl-$CURL_VERSION.tar.bz2
  tar jxf curl-$CURL_VERSION.tar.bz2 

  cd curl-$CURL_VERSION
  ./configure --prefix=$LIB_INSTALL_PATH/host-libcurl $COMMON_CURL_CONFIGURE_OPTS
  make
  make install
  
  setenv_i386
  ./configure --prefix=$LIB_INSTALL_PATH/i386-libcurl --host=i386-apple-darwin $COMMON_CURL_CONFIGURE_OPTS
  make
  make install
  make clean

  setenv_arm7
  ./configure --prefix=$LIB_INSTALL_PATH/arm7-libcurl --host=armv7-apple-darwin $COMMON_CURL_CONFIGURE_OPTS
  make
  make install
  make clean
  
  setenv_arm7s
  ./configure --prefix=$LIB_INSTALL_PATH/arm7s-libcurl --host=armv7s-apple-darwin $COMMON_CURL_CONFIGURE_OPTS
  make
  make install
  make clean
  
  mkdir -p $LIB_INSTALL_PATH/common-libcurl/lib $LIB_INSTALL_PATH/common-libcurl/include
  cp -r $LIB_INSTALL_PATH/host-libcurl/include/* $LIB_INSTALL_PATH/common-libcurl/include
  lipo -create -output $LIB_INSTALL_PATH/common-libcurl/lib/libcurl.a $LIB_INSTALL_PATH/arm7s-libcurl/lib/libcurl.a \
    $LIB_INSTALL_PATH/arm7-libcurl/lib/libcurl.a $LIB_INSTALL_PATH/i386-libcurl/lib/libcurl.a $LIB_INSTALL_PATH/host-libcurl/lib/libcurl.a 
  
fi
# 
# cd $LIB_SRC_PATH
# git clone https://github.com/ederoyd46/parson.git



