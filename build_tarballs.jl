# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "liblsl"
version = v"1.13.0-b13"

# Collection of sources required to build liblsl
sources = [
    "https://github.com/sccn/liblsl/archive/1.13.0-b13.tar.gz" =>
    "b7a1050cf4705d3d9917f7570e27e0c90c189634ecfc76906ecbfed45435b565",

]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
cd $WORKSPACE/srcdir
cd liblsl-1.13.0-b13/
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=$prefix -DCMAKE_TOOLCHAIN_FILE=/opt/$target/$target.toolchain -DCMAKE_BUILD_TYPE=Release -DLSL_UNIXFOLDERS=1 -DLSL_LSLBOOST_PATH="lslboost" ../
cmake --build . --config Release --target lsl

if [[ ${target} == *-linux-* ]]; then
    cp liblsl*.so.1.13.0 $prefix/liblsl.so
fi

if [[ ${target} == *-freebsd* ]]; then
    cp liblsl*.so.1.13.0 $prefix/liblsl.so
fi

if [[ ${target} == *-apple-* ]]; then
    cp liblsl64.dylib $prefix/liblsl.dylib
fi

if [[ ${target} == *-mingw* ]]; then
    cp liblsl*.dll $prefix/liblsl.dll
fi

exit


"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    Linux(:i686, libc=:glibc),
    Linux(:x86_64, libc=:glibc),
    Linux(:aarch64, libc=:glibc),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf),
    Linux(:powerpc64le, libc=:glibc),
    Linux(:i686, libc=:musl),
    Linux(:x86_64, libc=:musl),
    Linux(:aarch64, libc=:musl),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf),
    MacOS(:x86_64),
    FreeBSD(:x86_64),
    Windows(:i686),
    Windows(:x86_64)
]

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "liblsl", :liblsl)
]

# Dependencies that must be installed before this package can be built
dependencies = [
    
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)

