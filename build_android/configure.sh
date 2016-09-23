#!/bin/bash

#export ANDROID_NDK=${HOME}/Library/Android/sdk/ndk-bundle
export ANDROID_NDK=${HOME}/Documents/android-ndk-r10e

echo ${ANDROID_NDK}

SOURCE="${BASH_SOURCE[0]}"
 while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
   DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
   SOURCE="$(readlink "$SOURCE")"
   [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlin#
 done
 DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

  (
mkdir -p build.armv7.debug
cd build.armv7.debug
cmake "$DIR/../release/" \
    -DCMAKE_TOOLCHAIN_FILE=$DIR/android-cmake/android.toolchain.cmake \
    -DANDROID_ABI=armeabi-v7a \
    -DANDROID_TOOLCHAIN_NAME=arm-linux-androideabi-clang3.6 \
    -DANDROID_STL=none \
    -DANDROID_STL_FORCE_FEATURES=ON \
     -DANDROID_NATIVE_API_LEVEL=android-9 \
    -DANDROID_GOLD_LINKER=OFF \
    -DCMAKE_BUILD_TYPE=Debug \
    -DANDROID_NDK="${ANDROID_NDK}"
make -j 1
    )

(
mkdir -p build.armv7.release
cd build.armv7.release
  cmake "${DIR}/../release/" \
    -DCMAKE_TOOLCHAIN_FILE=$DIR/android-cmake/android.toolchain.cmake \
      -DANDROID_ABI=armeabi-v7a \
      -DANDROID_TOOLCHAIN_NAME=arm-linux-androideabi-clang3.6 \
      -DANDROID_STL=none \
      -DANDROID_STL_FORCE_FEATURES=ON \
     -DANDROID_NDK="${ANDROID_NDK}" \
     -DANDROID_NATIVE_API_LEVEL=android-9 \
     -DANDROID_GOLD_LINKER=OFF \
     -DCMAKE_BUILD_TYPE=Release
 make -j 1
)

(
mkdir -p build.x86.debug
  cd build.x86.debug
  cmake "${DIR}/../release/" \
  -DCMAKE_TOOLCHAIN_FILE=$DIR/android-cmake/android.toolchain.cmake \
  -DANDROID_ABI=x86 \
  -DANDROID_TOOLCHAIN_NAME=x86-clang3.6 \
  -DANDROID_STL=none \
  -DANDROID_STL_FORCE_FEATURES=ON \
  -DANDROID_NATIVE_API_LEVEL=android-9 \
  -DANDROID_GOLD_LINKER=OFF \
  -DCMAKE_BUILD_TYPE=Debug \
  -DANDROID_NDK="${ANDROID_NDK}"
  make -j 1
)

(
mkdir -p build.x86.release
cd build.x86.release
  cmake "${DIR}/../release/" \
    -DCMAKE_TOOLCHAIN_FILE=$DIR/android-cmake/android.toolchain.cmake \
    -DANDROID_ABI=x86 \
    -DANDROID_TOOLCHAIN_NAME=x86-clang3.6 \
    -DANDROID_STL=none \
    -DANDROID_STL_FORCE_FEATURES=ON \
    -DANDROID_NDK="${ANDROID_NDK}" \
    -DANDROID_NATIVE_API_LEVEL=android-9 \
    -DANDROID_GOLD_LINKER=OFF \
    -DCMAKE_BUILD_TYPE=Release
make -j 1
     )
