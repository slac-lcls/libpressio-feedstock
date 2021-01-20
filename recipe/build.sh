#!/bin/bash -x -e

declare -a CMAKE_PLATFORM_FLAGS
CMAKE_PLATFORM_FLAGS+=(-DCMAKE_FIND_ROOT_PATH="${PREFIX};${BUILD_PREFIX}/${HOST}/sysroot")
CMAKE_PLATFORM_FLAGS+=(-DCMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES:PATH="${BUILD_PREFIX}/${HOST}/sysroot/usr/include")

if [[ ${DEBUG_C} == yes ]]; then
  CMAKE_BUILD_TYPE=Debug
else
  CMAKE_BUILD_TYPE=Release
fi


export LDFLAGS="-lrt"
export PKG_CONFIG_PATH=${CONDA_PREFIX}/share/pkgconfig:${CONDA_PREFIX}/lib/pkgconfig:$PKG_CONFIG_PATH

env |sort

mkdir build
cd build
${BUILD_PREFIX}/bin/cmake --version
${BUILD_PREFIX}/bin/cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
  -DBUILD_SHARED_LIBS=ON \
  -DBUILD_PYTHON_WRAPPER=ON \
  -DPython3_EXECUTABLE=$(which python) \
  -DLIBPRESSIO_HAS_SZ=ON  \
  -DLIBPRESSIO_HAS_HDF=ON  \
  -DLIBPRESSIO_CXX_VERSION=11 \
  -DBUILD_TESTING=OFF \
  "${CMAKE_PLATFORM_FLAGS[@]}" \
  ${SRC_DIR}

${BUILD_PREFIX}/bin/make -j${CPU_COUNT}
${BUILD_PREFIX}/bin/make install PREFIX=${PREFIX}
