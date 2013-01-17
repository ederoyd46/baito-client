#!/bin/bash
BASE_PATH=`pwd`
uname=`uname`
LIB_SRC_PATH=$BASE_PATH/tmp
LIB_INSTALL_PATH=$BASE_PATH/lib
CURL_VERSION=7.28.1
IOS_BASE_SDK="6.0"
IOS_DEPLOY_TGT="6.0"

COMMON_CONFIGURE_OPTS="--disable-shared --enable-static --with-darwinssl --without-ssl --without-libssh2 --without-librtmp --without-libidn --without-ca-bundle --enable-http --disable-rtsp --disable-ftp --disable-file --disable-ldap --disable-ldaps --disable-dict --disable-telnet --disable-tftp --disable-pop3 --disable-imap --disable-smtp --disable-gopher"

setenv_all()
{
  # Don't seem to be need although were part of the original posting
  # export PATH="$DEVROOT/usr/bin:$PATH"
  # export CPP="$DEVROOT/usr/bin/cpp"
  # export CXXCPP="$DEVROOT/usr/bin/cpp"
  # export LD="$DEVROOT/usr/bin/ld"
  # export AR="$DEVROOT/usr/bin/ar"
  # export AS="$DEVROOT/usr/bin/as"
  # export NM="$DEVROOT/usr/bin/nm"
  # export RANLIB="$DEVROOT/usr/bin/ranlib"
  # export CPPFLAGS=$CFLAGS
  # export CXXFLAGS=$CFLAGS

  export CC="$DEVROOT/usr/bin/gcc"
  export CXX="$DEVROOT/usr/bin/g++"
  export CFLAGS=$CFLAGS
  export LDFLAGS="$LDFLAGS"
}

setenv_arm7()
{
  unset DEVROOT SDKROOT CFLAGS CC LD CPP CXX AR AS NM CXXCPP RANLIB LDFLAGS CPPFLAGS CXXFLAGS
  export DEVROOT=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer
  export SDKROOT=$DEVROOT/SDKs/iPhoneOS$IOS_BASE_SDK.sdk
  export CFLAGS="-arch armv7 -pipe -no-cpp-precomp -isysroot $SDKROOT -miphoneos-version-min=$IOS_DEPLOY_TGT -I$SDKROOT/usr/include/ -L$SDKROOT/usr/lib/" 
  setenv_all
}

setenv_arm7s()
{
  unset DEVROOT SDKROOT CFLAGS CC LD CPP CXX AR AS NM CXXCPP RANLIB LDFLAGS CPPFLAGS CXXFLAGS
  export DEVROOT=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer
  export SDKROOT=$DEVROOT/SDKs/iPhoneOS$IOS_BASE_SDK.sdk
  export CFLAGS="-arch armv7s -pipe -no-cpp-precomp -isysroot $SDKROOT -miphoneos-version-min=$IOS_DEPLOY_TGT -I$SDKROOT/usr/include/ -L$SDKROOT/usr/lib/"
  setenv_all
}

setenv_i386()
{
  unset DEVROOT SDKROOT CFLAGS CC LD CPP CXX AR AS NM CXXCPP RANLIB LDFLAGS CPPFLAGS CXXFLAGS
  export DEVROOT=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer
  export SDKROOT=$DEVROOT/SDKs/iPhoneSimulator$IOS_BASE_SDK.sdk
  export CFLAGS="-arch i386 -pipe -no-cpp-precomp -isysroot $SDKROOT -miphoneos-version-min=$IOS_DEPLOY_TGT"
  setenv_all
}
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

