#!/bin/bash
IOS_BASE_SDK="6.0"
IOS_DEPLOY_TGT="6.0"

BASE_DIR=`pwd`
LIB_CURL="$BASE_DIR/lib/ios-libcurl/ios-dev"
SRC_DIR=$BASE_DIR/src
BUILD_DIR=$BASE_DIR/build


setenv_all()
{
  # Add internal
  export CPP="$DEVROOT/usr/bin/cpp"
  export CXX="$DEVROOT/usr/bin/g++"
  export CXXCPP="$DEVROOT/usr/bin/cpp"
  export CC="$DEVROOT/usr/bin/llvm-gcc-4.2"
  export LD="$DEVROOT/usr/bin/ld"
  export AR="$DEVROOT/usr/bin/ar"
  export AS="$DEVROOT/usr/bin/as"
  export NM="$DEVROOT/usr/bin/nm"
  export RANLIB="$DEVROOT/usr/bin/ranlib"

  export CFLAGS=$CFLAGS
  export CPPFLAGS=$CFLAGS
  export CXXFLAGS=$CFLAGS
  export LDFLAGS="-L$SDKROOT/usr/lib/ $LDFLAGS"
}

# setenv_arm6()
# {
#   unset DEVROOT SDKROOT CFLAGS CC LD CPP CXX AR AS NM CXXCPP RANLIB LDFLAGS CPPFLAGS CXXFLAGS
#   export DEVROOT=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer
#   export SDKROOT=$DEVROOT/SDKs/iPhoneOS$IOS_BASE_SDK.sdk
#   export CFLAGS="-arch armv6 -pipe -no-cpp-precomp -isysroot $SDKROOT -miphoneos-version-min=$IOS_DEPLOY_TGT -I$SDKROOT/usr/include/"
#   setenv_all
# }

setenv_arm7()
{
  unset DEVROOT SDKROOT CFLAGS CC LD CPP CXX AR AS NM CXXCPP RANLIB LDFLAGS CPPFLAGS CXXFLAGS
  export DEVROOT=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer
  export SDKROOT=$DEVROOT/SDKs/iPhoneOS$IOS_BASE_SDK.sdk
  export CFLAGS="-arch armv7 -pipe -no-cpp-precomp -isysroot $SDKROOT -miphoneos-version-min=$IOS_DEPLOY_TGT -I$SDKROOT/usr/include/ -I$LIB_CURL/include/" 
  export LDFLAGS="-L$LIB_CURL/lib/ -lcurl"
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
setenv_arm7

echo $LDFLAGS
$CC $CFLAGS $LDFLAGS -o $BUILD_DIR/baito-client $SRC_DIR/main.c $SRC_DIR/parson.c $SRC_DIR/baito.c




# create_outdir_lipo()
# {
#   for lib_i386 in `find $OUTDIR/i386 -name "lib*\.a"`; do
#     lib_arm6=`echo $lib_i386 | sed "s/i386/arm6/g"`
#     lib_arm7=`echo $lib_i386 | sed "s/i386/arm7/g"`
#     lib=`echo $lib_i386 | sed "s/i386\///g"`
#     lipo -arch armv6 $lib_arm6 -arch armv7 $lib_arm7 -arch i386 $lib_i386 -create -output $lib
#   done
# }
# 
# merge_libfiles()
# {
#   DIR=$1
#   LIBNAME=$2
#   cd $DIR
#   for i in `find . -name "lib*.a"`; do
#     $AR -x $i
#   done
#   $AR -r $LIBNAME *.o
#   rm -rf *.o __*
#   cd -
# }

