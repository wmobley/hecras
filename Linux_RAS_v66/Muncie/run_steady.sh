#!/bin/sh
# Run RasSteady compute

RAS_LIB_PATH=../libs:../libs/mkl:../libs/rhel_8 

export LD_LIBRARY_PATH=$RAS_LIB_PATH:$LD_LIBRARY_PATH
echo $LD_LIBRARY_PATH

#RAS_EXE_PATH=../RAS_v65/Debug
RAS_EXE_PATH=../RAS_v65/Release
export PATH=$RAS_EXE_PATH:$PATH
echo $PATH

RasSteady Muncie.r04

