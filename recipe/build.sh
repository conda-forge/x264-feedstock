#!/bin/bash

mkdir -vp ${PREFIX}/bin

# Set the assembler to `nasm`
export AS="${BUILD_PREFIX}/bin/nasm"

CFLAGS="-Wall -g -m64 -pipe -O2 -fPIC"
if [[ $ARCH = 64 ]]; then
    CFLAGS="${CFLAGS} -march=x86-64"
else
    CFLAGS="${CFLAGS} -march=i386"
fi
export CFLAGS
export CXXFLAGS="${CXXFLAGS} ${CFLAGS}"

chmod +x configure
./configure \
        --enable-pic \
        --enable-shared \
        --enable-static \
        --prefix=${PREFIX}
make
make install
