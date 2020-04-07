#!/bin/bash


cd $CODEROOT/atm/WRFV3

rm $CODEROOT/atm/WRFV3/main/wrf.exe
./compile em_real 
cp $CODEROOT/atm/WRFV3/main/wrf.exe $CODEROOT/../../WRF_MITgcm/run/atm/wrf/exe/wrf
