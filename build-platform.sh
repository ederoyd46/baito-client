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

  echo Configuring host see /tmp/build-platform-configure-openssl-host.log
  ./Configure darwin64-x86_64-cc --prefix=$LIB_INSTALL_PATH/host-libssl &> /tmp/build-platform-configure-openssl-host.log

  echo Building host see /tmp/build-platform-build-openssl-host.log
  make &> /tmp/build-platform-build-openssl-host.log

  echo Installing host see /tmp/build-platform-install-openssl-host.log
  make install &> /tmp/build-platform-install-openssl-host.log

  build_openssl() {
    COMPILER=$1
    ARCH=$2
    IOS_SDK_ROOT=$3
    
    echo ARCH $ARCH
    
    cd $LIB_SRC_PATH
    rm -rf openssl-$SSL_VERSION
    tar zxf openssl-$SSL_VERSION.tar.gz
    cd openssl-$SSL_VERSION
    
    echo Configuring $ARCH see /tmp/build-platform-configure-openssl-$ARCH.log
    ./Configure BSD-generic32 --prefix=$LIB_INSTALL_PATH/$ARCH-libssl &>/tmp/build-platform-configure-openssl-$ARCH.log
    perl -i -pe 's|static volatile sig_atomic_t intr_signal|static volatile int intr_signal|' crypto/ui/ui_openssl.c
    perl -i -pe "s|^CC= gcc|CC= ${COMPILER} -arch ${ARCH}|g" Makefile
    perl -i -pe "s|^CFLAG= (.*)|CFLAG= -isysroot ${IOS_SDK_ROOT} \$1|g" Makefile

    echo Building $ARCH see /tmp/build-platform-build-openssl-$ARCH.log
    make &> /tmp/build-platform-build-openssl-$ARCH.log

    echo Installing $ARCH see /tmp/build-platform-install-openssl-$ARCH.log
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
  COMMON_CURL_CONFIGURE_OPTS="--disable-shared --enable-static --without-darwinssl --without-libssh2 --without-librtmp --without-libidn --without-ca-bundle --enable-http --disable-rtsp --disable-ftp --disable-file --disable-ldap --disable-ldaps --disable-dict --disable-telnet --disable-tftp --disable-pop3 --disable-imap --disable-smtp --disable-gopher"
  cd $LIB_SRC_PATH
  curl -C - -O http://curl.haxx.se/download/curl-$CURL_VERSION.tar.bz2
  tar jxf curl-$CURL_VERSION.tar.bz2 

  build_curl() {
    ARCH=$1
    HOST=$2
    EXTRA_CONFIGURE_OPTS=$3
    cd $LIB_SRC_PATH/curl-$CURL_VERSION
    make clean
    
    echo Configuring $ARCH see /tmp/build-platform-configure-libcurl-$ARCH.log
    ./configure --prefix=$LIB_INSTALL_PATH/$ARCH-libcurl $HOST $COMMON_CURL_CONFIGURE_OPTS $EXTRA_CONFIGURE_OPTS &> /tmp/build-platform-configure-libcurl-$ARCH.log
    echo Building $ARCH see /tmp/build-platform-build-libcurl-$ARCH.log
    make &> /tmp/build-platform-build-libcurl-$ARCH.log
    echo Installing $ARCH see /tmp/build-platform-install-libcurl-$ARCH.log
    make install &> /tmp/build-platform-install-libcurl-$ARCH.log
  }
  
  
  build_curl "host" "" "--with-ssl=$LIB_INSTALL_PATH/host-libssl"
  
  setenv_i386
  build_curl "i386" "--host=i386-apple-darwin" "--with-ssl=$LIB_INSTALL_PATH/i386-libssl"
  
  setenv_arm7
  build_curl "armv7" "--host=armv7-apple-darwin" "--with-ssl=$LIB_INSTALL_PATH/armv7-libssl"
  
  setenv_arm7s
  build_curl "armv7s" "--host=armv7s-apple-darwin" "--with-ssl=$LIB_INSTALL_PATH/arm7s-libssl"
  
  mkdir -p $LIB_INSTALL_PATH/common-libcurl/lib $LIB_INSTALL_PATH/common-libcurl/include
  cp -r $LIB_INSTALL_PATH/host-libcurl/include/* $LIB_INSTALL_PATH/common-libcurl/include
  lipo -create -output $LIB_INSTALL_PATH/common-libcurl/lib/libcurl.a $LIB_INSTALL_PATH/armv7s-libcurl/lib/libcurl.a \
    $LIB_INSTALL_PATH/armv7-libcurl/lib/libcurl.a $LIB_INSTALL_PATH/i386-libcurl/lib/libcurl.a $LIB_INSTALL_PATH/host-libcurl/lib/libcurl.a 
  
fi
# 
cd $LIB_SRC_PATH
git clone https://github.com/ederoyd46/parson.git



