#!/bin/bash
set -xe
mkdir -vp ${PREFIX}/bin

# Set the assembler to `nasm`
if [[ ${target_platform} == "linux-64" || ${target_platform} == "osx-64" || ${target_platform} == "linux-aarch64" ]]; then
    export AS="${BUILD_PREFIX}/bin/nasm"
fi

if [ ${target_platform} == "linux-aarch64" ]; then
    unset AS
fi


# if [ ${target_platform} == "linux-aarch64" ]; then
#     export CFLAGS="-mpreferred-stack-boundary=8 ${CFLAGS}"
#     export CXXFLAGS="-mpreferred-stack-boundary=8 ${CXXFLAGS}"
# fi

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
        $EXTRA_CONFIG \
        --prefix=${PREFIX}
make
make install
