#!/bin/sh
set -eu

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
MODEL_ROOT="${SCRIPT_DIR}/Linux_RAS_v66"
MODEL_DIR="${MODEL_ROOT}/Muncie"
OUTPUT_DIR=${_tapisExecSystemOutputDir:-}
RUNNER=${1:-run_steady.sh}

case "$RUNNER" in
  run_steady.sh|run_unsteady.sh) ;;
  *)
    echo "Unsupported run option: $RUNNER" >&2
    exit 1
    ;;
esac

echo "Running $RUNNER in $MODEL_DIR"

RAS_LIB_PATH="${MODEL_ROOT}/libs:${MODEL_ROOT}/libs/mkl:${MODEL_ROOT}/libs/rhel_8"
ORIGINAL_LD_LIBRARY_PATH=${LD_LIBRARY_PATH-}
if [ -n "$ORIGINAL_LD_LIBRARY_PATH" ]; then
  export LD_LIBRARY_PATH="${RAS_LIB_PATH}:$ORIGINAL_LD_LIBRARY_PATH"
else
  export LD_LIBRARY_PATH="${RAS_LIB_PATH}"
fi
echo "$LD_LIBRARY_PATH"

RAS_EXE_PATH="${MODEL_ROOT}/RAS_v65/Release"
ORIGINAL_PATH=${PATH-}
if [ -n "$ORIGINAL_PATH" ]; then
  export PATH="${RAS_EXE_PATH}:$ORIGINAL_PATH"
else
  export PATH="${RAS_EXE_PATH}"
fi
echo "$PATH"

cd "$MODEL_DIR"

if [ "$RUNNER" = "run_steady.sh" ]; then
  RasSteady Muncie.r04
else
  RasUnsteady Muncie.p04.tmp.hdf x04
  mv Muncie.p04.tmp.hdf Muncie.p04.hdf
fi

if [ -n "$OUTPUT_DIR" ]; then
  mkdir -p "$OUTPUT_DIR"
  cp -a "$MODEL_DIR/." "$OUTPUT_DIR/"
fi
