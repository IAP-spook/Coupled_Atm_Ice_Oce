#!/bin/sh
cd ./build
rm *
../MITgcm_c64a/tools/genmake2  -rootdir=../MITgcm_c64a -mods=../code -mpi -of=../MITgcm_c64a/tools/build_options/linux_ifort+mpi_swell
make depend
make -j 2
