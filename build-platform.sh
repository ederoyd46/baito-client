#!/bin/bash
BASE_PATH=`pwd`
uname=`uname`
LIB_SRC_PATH=$BASE_PATH/tmp
LIB_INSTALL_PATH=$BASE_PATH/lib
CURL_VERSION=7.28.1
IOS_BASE_SDK="6.0"
IOS_DEPLOY_TGT="6.0"

COMMON_CONFIGURE_OPTS=--disable-shared --enable-static --with-darwinssl --without-ssl --without-libssh2 --without-librtmp --without-libidn --without-ca-bundle --enable-http --disable-rtsp --disable-ftp --disable-file --disable-ldap --disable-ldaps --disable-dict --disable-telnet --disable-tftp --disable-pop3 --disable-imap --disable-smtp --disable-gopher

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

setenv_arm6()
{
  unset DEVROOT SDKROOT CFLAGS CC LD CPP CXX AR AS NM CXXCPP RANLIB LDFLAGS CPPFLAGS CXXFLAGS
  export DEVROOT=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer
  export SDKROOT=$DEVROOT/SDKs/iPhoneOS$IOS_BASE_SDK.sdk
  export CFLAGS="-arch armv6 -pipe -no-cpp-precomp -isysroot $SDKROOT -miphoneos-version-min=$IOS_DEPLOY_TGT -I$SDKROOT/usr/include/ -L$SDKROOT/usr/lib/"
  setenv_all
}

setenv_arm7()
{
  unset DEVROOT SDKROOT CFLAGS CC LD CPP CXX AR AS NM CXXCPP RANLIB LDFLAGS CPPFLAGS CXXFLAGS
  export DEVROOT=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer
  export SDKROOT=$DEVROOT/SDKs/iPhoneOS$IOS_BASE_SDK.sdk
  export CFLAGS="-arch armv7 -pipe -no-cpp-precomp -isysroot $SDKROOT -miphoneos-version-min=$IOS_DEPLOY_TGT -I$SDKROOT/usr/include/ -L$SDKROOT/usr/lib/" 
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


cd curl-$CURL_VERSION
./configure --prefix=$LIB_INSTALL_PATH/host-libcurl 
make
make install


if [ "$uname" == 'Darwin' ]; then
  setenv_i386
  ./configure --prefix=$LIB_INSTALL_PATH/i386-libcurl --host=i386-apple-darwin $COMMON_CONFIGURE_OPTS
  make
  make install

  setenv_arm6
  ./configure --prefix=$LIB_INSTALL_PATH/arm6-libcurl --host=armv6-apple-darwin $COMMON_CONFIGURE_OPTS
  make
  make install

  setenv_arm7
  ./configure --prefix=$LIB_INSTALL_PATH/arm7-libcurl --host=armv7-apple-darwin $COMMON_CONFIGURE_OPTS
  make
  make install
fi

# make
# make install
# 
# cd $LIB_SRC_PATH
# git clone https://github.com/ederoyd46/parson.git
# 
# if [ "$uname" == 'Darwin' ]; then
#   # Make sure a recent version of ruby is installed using 'brew install ruby' and modify the PATH to include it.
#   git clone https://github.com/ederoyd46/curl-ios-build-scripts
#   cd curl-ios-build-scripts
#   ./build_curl --libcurl-version $CURL_VERSION --no-cleanup
#   
#   cd curl
#   mkdir -p $LIB_INSTALL_PATH/ios-libcurl
#   cp -r * $LIB_INSTALL_PATH/ios-libcurl
# fi


