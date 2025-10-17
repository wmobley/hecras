#!/bin/sh
# Run RasUnsteady 

RAS_LIB_PATH=../libs:../libs/mkl:../libs/rhel_8 

export LD_LIBRARY_PATH=$RAS_LIB_PATH:$LD_LIBRARY_PATH
echo $LD_LIBRARY_PATH

#RAS_EXE_PATH=../RAS_v65/Debug
RAS_EXE_PATH=../RAS_v65/Release
export PATH=$RAS_EXE_PATH:$PATH
echo $PATH

RasUnsteady Muncie.p04.tmp.hdf x04

# rename the hdf file
mv Muncie.p04.tmp.hdf Muncie.p04.hdf

