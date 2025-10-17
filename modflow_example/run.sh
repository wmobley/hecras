#!/bin/bash
set -xe


checkExitCode() {
if [ $? -ne 0 ]; then
    echo "Error"
    exit 1;
fi
}

INPUTS_DIR=${_tapisExecSystemInputDir}
OUTPUTS_DIR=${_tapisExecSystemOutputDir}
NAM=${OUTPUTS_DIR}/tmp.nam

echo "## MODFLOW-2005 name-file" >> $NAM
echo "LIST    7    LST" >> $NAM

# Required files
if [ -f "${INPUTS_DIR}/input.ba6" ]; then
    BAS6=$(basename ${INPUTS_DIR}/input.ba6)
    echo "BAS6    1    $BAS6" >> $NAM
fi

if [ -f "${INPUTS_DIR}/input.dis" ]; then
    DIS=$(basename ${INPUTS_DIR}/input.dis)
    echo "DIS    29    $DIS" >> $NAM
fi

if [ -f "${INPUTS_DIR}/input.oc" ]; then
    OC=$(basename ${INPUTS_DIR}/input.oc)
    echo "OC    22    $OC" >> $NAM
fi

# Flow packages (optional - only one should be used)
if [ -f "${INPUTS_DIR}/input.lpf" ]; then
    LPF=$(basename ${INPUTS_DIR}/input.lpf)
    echo "LPF    11    $LPF" >> $NAM
elif [ -f "${INPUTS_DIR}/input.bc6" ]; then
    BCF6=$(basename ${INPUTS_DIR}/input.bc6)
    echo "BCF6    11    $BCF6" >> $NAM
fi

# Optional stress packages
if [ -f "${INPUTS_DIR}/input.zone" ]; then
    ZONE=$(basename ${INPUTS_DIR}/input.zone)
    echo "ZONE    40    $ZONE" >> $NAM
fi

if [ -f "${INPUTS_DIR}/input.wel" ]; then
    WEL=$(basename ${INPUTS_DIR}/input.wel)
    echo "WEL    12    $WEL" >> $NAM
fi

if [ -f "${INPUTS_DIR}/input.drn" ]; then
    DRN=$(basename ${INPUTS_DIR}/input.drn)
    echo "DRN    13    $DRN" >> $NAM
fi

if [ -f "${INPUTS_DIR}/input.riv" ]; then
    RIV=$(basename ${INPUTS_DIR}/input.riv)
    echo "RIV    14    $RIV" >> $NAM
fi

if [ -f "${INPUTS_DIR}/input.evt" ]; then
    EVT=$(basename ${INPUTS_DIR}/input.evt)
    echo "EVT    20    $EVT" >> $NAM
fi

if [ -f "${INPUTS_DIR}/input.ghb" ]; then
    GHB=$(basename ${INPUTS_DIR}/input.ghb)
    echo "GHB    17    $GHB" >> $NAM
fi

if [ -f "${INPUTS_DIR}/input.rch" ]; then
    RCH=$(basename ${INPUTS_DIR}/input.rch)
    echo "RCH    18    $RCH" >> $NAM
fi

if [ -f "${INPUTS_DIR}/input.hf6" ]; then
    HFB6=$(basename ${INPUTS_DIR}/input.hf6)
    echo "HFB6    26    $HFB6" >> $NAM
fi

# Solver packages (optional - only one should be used)
if [ -f "${INPUTS_DIR}/input.pcg" ]; then
    PCG=$(basename ${INPUTS_DIR}/input.pcg)
    echo "PCG    19    $PCG" >> $NAM
elif [ -f "${INPUTS_DIR}/input.sip" ]; then
    SIP=$(basename ${INPUTS_DIR}/input.sip)
    echo "SIP    19    $SIP" >> $NAM
fi

# Output files
echo "DATA(BINARY)    50    CBB" >> $NAM
echo "DATA(BINARY)    30    HDS" >> $NAM
echo "DATA(BINARY)    31    DDN" >> $NAM

mf2005 $NAM

# Move output files if they exist
if [ -f "LST" ]; then
    mv LST ${OUTPUTS_DIR}/LST
fi
if [ -f "CBB" ]; then
    mv CBB ${OUTPUTS_DIR}/CBB
fi
if [ -f "HDS" ]; then
    mv HDS ${OUTPUTS_DIR}/HDS
fi
if [ -f "DDN" ]; then
    mv DDN ${OUTPUTS_DIR}/DDN
fi
checkExitCode