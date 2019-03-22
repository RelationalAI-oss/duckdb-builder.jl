# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "duckdb"
version = v"0.0.0"

# Collection of sources required to build tpch-dbgen
sources = [
    joinpath(pwd(),"duckdb")
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir

sed -i 's|add_subdirectory(tools)||' CMakeLists.txt
sed -i 's|add_subdirectory(benchmark)||' CMakeLists.txt
sed -i 's|add_subdirectory(test)||' CMakeLists.txt
sed -i 's|add_subdirectory(sqlsmith)||' third_party/CMakeLists.txt

mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
if [ $target = "x86_64-apple-darwin14" ]; then
  sed -i 's|-soname,libduckdb.so -o libduckdb.so|-install_name,libduckdb.dylib -o libduckdb.dylib|' ./src/CMakeFiles/duckdb.dir/link.txt
fi
make -j$(nproc)
mkdir $prefix/lib
cp -R src/libduckdb.* $prefix/lib/
cp -R src/include $prefix/include
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    Linux(:x86_64, libc=:glibc, compiler_abi=CompilerABI(:gcc7, :cxx11))
    MacOS(:x86_64)
]

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libduckdb", :libduckdb)
]

# Dependencies that must be installed before this package can be built
dependencies = [
    
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)

