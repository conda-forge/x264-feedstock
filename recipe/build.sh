#!/bin/bash
set -xe
mkdir -vp ${PREFIX}/bin

# Set the assembler to `nasm`
if [[ ${platform} == "linux-64" || ${platform} == "osx-64" ]]; then
    export AS="${BUILD_PREFIX}/bin/nasm"
fi

# EXTRA_CFLAGS="-Wall -g -m64 -pipe -O2 -fPIC"
# if [[ $ARCH = 64 ]]; then
#     EXTRA_CFLAGS="${EXTRA_CFLAGS} -march=x86-64"
# else
#     EXTRA_CFLAGS="${EXTRA_CFLAGS} -march=i386"
# fi
# export CFLAGS="${CFLAGS} ${EXTRA_CFLAGS}"
# export CXXFLAGS="${CXXFLAGS} ${EXTRA_CFLAGS}"

chmod +x configure
./configure \
        --enable-pic \
        --enable-shared \
        --enable-static \
        --prefix=${PREFIX}
make
make install
