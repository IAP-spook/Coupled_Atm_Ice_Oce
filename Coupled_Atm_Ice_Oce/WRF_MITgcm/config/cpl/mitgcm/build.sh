#!/bin/bash

export env=${1}
export exedir=${2}
export makefile=${3}
export ntasks=${4}
export nthrds=${5}
export grid=${6}

cd $CODEROOT/cpl/Atm_Ice_Oce

cd ./build
rm mitgcmuv
make depend
make -j 8
cp $CODEROOT/cpl/Atm_Ice_Oce/build/mitgcmuv  $CODEROOT/../../WRF_MITgcm/run/cpl/mitgcm/exe/mitgcm
