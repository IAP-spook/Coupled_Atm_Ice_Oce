#!/bin/bash

export Env=$1
export Libdir=$2
export Makefile=$3

source $Env

#cd $Libdir/obj
cd $CODEROOT/libs/c_coupler/build
./build.sh
#gmake -j $GMAKE_J  -f $Makefile || exit 1
#echo $LibDir
#cp -f $Libdir/exe/libc_coupler.a $LIBROOT/
#cp *.mod $LIBROOT/include

exit 0
