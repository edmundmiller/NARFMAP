# NARFMAP

NARFMAP is a fork of the Dragen mapper/aligner Open Source Software.

## Installation

### Using bioconda

Coming Soon™️

### Build from source

#### Nix

1. Install nix. The Determinate Systems Installer is recommended for Flakes.

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

2. Run `nix build`

#### If you're feeling bold

We're still using the previous build system under the hood

##### Prerequisites

Compilation was tested on CentOS 7

- C++17 compatible compiler (e.g gcc-c++ >= 7.1)
- GNU make >= 3.82
- Boost library : boost169-devel >= 1.69.0-1.el7
- For unit tests : googletest (>= v1.6)
- Hardware: x86_86, 64GB RAM minimum
- OS: Centos >= 7.7

##### Install

The basic procedure is

    make

Binary will be generated in ./build/release/

Then optionally, to install to /usr/bin/

    make install

By default make will compile and launch unit tests. To disable unit tests, use HAS_GTEST=0, e.g. :

    HAS_GTEST=0 make

To compile with unit tests, if google test was installed in user space, it might be required to set GTEST_ROOT and LD_LIBRARY_PATH to where gtest was installed, e.g. :

    export GTEST_ROOT=/home/username/lib/gtest
    export LD_LIBRARY_PATH=/home/username/lib/gtest/lib

##### Other variables controlling the build process:

- GCC_BASE
- CXX
- BOOST_ROOT
- BOOST_INCLUDEDIR
- BOOST_LIBRARYDIR

## Pull requests

We are accepting pull requests into this repository at this time! For any bug report / recommendation / feature request, please open an issue. Stay tuned for a `CONTRIBUTING.md`
