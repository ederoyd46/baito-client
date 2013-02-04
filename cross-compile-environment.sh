IOS_BASE_SDK="6.1"
IOS_DEPLOY_TGT="6.1"

setenv_all()
{
  # Don't seem to be need although were part of the original posting
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
}

setenv_arm7()
{
  unset DEVROOT SDKROOT CFLAGS CC LD CPP CXX AR AS NM CXXCPP RANLIB LDFLAGS CPPFLAGS CXXFLAGS ARCH
  export DEVROOT=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer
  export SDKROOT=$DEVROOT/SDKs/iPhoneOS$IOS_BASE_SDK.sdk
  export CFLAGS="-arch armv7 -pipe -no-cpp-precomp -isysroot $SDKROOT -miphoneos-version-min=$IOS_DEPLOY_TGT -I$SDKROOT/usr/include/ -L$SDKROOT/usr/lib/" 
  setenv_all
}

setenv_arm7s()
{
  unset DEVROOT SDKROOT CFLAGS CC LD CPP CXX AR AS NM CXXCPP RANLIB LDFLAGS CPPFLAGS CXXFLAGS ARCH
  export DEVROOT=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer
  export SDKROOT=$DEVROOT/SDKs/iPhoneOS$IOS_BASE_SDK.sdk
  export CFLAGS="-arch armv7s -pipe -no-cpp-precomp -isysroot $SDKROOT -miphoneos-version-min=$IOS_DEPLOY_TGT -I$SDKROOT/usr/include/ -L$SDKROOT/usr/lib/"
  setenv_all
}

setenv_i386()
{
  unset DEVROOT SDKROOT CFLAGS CC LD CPP CXX AR AS NM CXXCPP RANLIB LDFLAGS CPPFLAGS CXXFLAGS ARCH
  export DEVROOT=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer
  export SDKROOT=$DEVROOT/SDKs/iPhoneSimulator$IOS_BASE_SDK.sdk
  export CFLAGS="-arch i386 -pipe -no-cpp-precomp -isysroot $SDKROOT -miphoneos-version-min=$IOS_DEPLOY_TGT"
  setenv_all
}
