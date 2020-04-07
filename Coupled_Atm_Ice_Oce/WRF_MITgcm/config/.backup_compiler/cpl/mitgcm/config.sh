#! /bin/csh -f

#-----------------------------------------------------------------------------------
# write out resolved prestaging directives
#-----------------------------------------------------------------------------------

echo "No need for configure."
cd $CODEROOT/cpl/Atm_Ice_Oce

cd ./build
rm *
rm  $CODEROOT/cpl/Atm_Ice_Oce/build/mitgcmuv

../MITgcm_c64a/tools/genmake2  -rootdir=../MITgcm_c64a -mods=../code -mpi -of=../MITgcm_c64a/tools/build_options/linux_ifort+mpi_swell

