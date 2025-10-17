#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_EXTRACTOR="${SCRIPT_DIR}/scripts/extract_archive.py"
INPUT_DIR="${_tapisExecSystemInputDir:-${SCRIPT_DIR}/inputs}"
OUTPUT_DIR="${_tapisExecSystemOutputDir:-${SCRIPT_DIR}/output}"
WORK_DIR="${_tapisExecSystemInputDir}/.hecras_work"
BASE_INSTALL_DIR="${_tapisExecSystemInputDir}/Linux_RAS_v66"
STAGED_INSTALL_DIR="${WORK_DIR}/Linux_RAS_v66"
MODEL_DIR="${STAGED_INSTALL_DIR}/Muncie"
USER_ARCHIVE_PATH="${INPUT_DIR}/project_archive"
RUN_CHOICE="${1:-run_steady.sh}"
LOG_FILE="${OUTPUT_DIR}/hecras-${RUN_CHOICE%.sh}.log"

log() {
  echo "[$(date --iso-8601=seconds)] $*"
}

fail() {
  log "ERROR: $*"
  exit 1
}

prepare_workspace() {
  rm -rf "${WORK_DIR}"
  mkdir -p "${WORK_DIR}" "${OUTPUT_DIR}"
  cp -a "${BASE_INSTALL_DIR}" "${WORK_DIR}/"
  log "Workspace prepared at ${WORK_DIR}"
}

link_release_layout() {
  mkdir -p "${STAGED_INSTALL_DIR}/RAS_v65"
  ln -sfn "${STAGED_INSTALL_DIR}/bin" "${STAGED_INSTALL_DIR}/RAS_v65/Release"
  log "Configured legacy RAS_v65 symlink."
}

validate_run_choice() {
  case "${RUN_CHOICE}" in
    run_steady.sh|run_unsteady.sh) ;;
    *) fail "Unsupported run option: ${RUN_CHOICE}. Supported: run_steady.sh, run_unsteady.sh." ;;
  esac

  if [[ ! -x "${MODEL_DIR}/${RUN_CHOICE}" ]]; then
    fail "Runner ${RUN_CHOICE} not found or not executable under ${MODEL_DIR}"
  fi

  log "Selected runner: ${RUN_CHOICE}"
}

extract_user_project() {
  if [[ ! -f "${USER_ARCHIVE_PATH}" || ! -s "${USER_ARCHIVE_PATH}" ]]; then
    log "No project archive supplied. Using bundled Muncie example."
    return
  fi

  [[ -x "${PYTHON_EXTRACTOR}" ]] || fail "Python extractor not found at ${PYTHON_EXTRACTOR}"

  local user_project_dir="${WORK_DIR}/project_input"
  rm -rf "${user_project_dir}"
  mkdir -p "${user_project_dir}"

  log "Expanding user archive ${USER_ARCHIVE_PATH}..."
  python3 "${PYTHON_EXTRACTOR}" "${USER_ARCHIVE_PATH}" "${user_project_dir}"

  if [[ -n "$(ls -A "${user_project_dir}")" ]]; then
    log "Merging extracted project files into model workspace..."
    cp -a "${user_project_dir}/." "${MODEL_DIR}/"
  else
    log "Archive extraction yielded no files; continuing with bundled project."
  fi
}

configure_runtime_env() {
  export LD_LIBRARY_PATH="${STAGED_INSTALL_DIR}/libs:${STAGED_INSTALL_DIR}/libs/mkl:${STAGED_INSTALL_DIR}/libs/rhel_8:${LD_LIBRARY_PATH:-}"
  export PATH="${STAGED_INSTALL_DIR}/bin:${PATH}"
  log "Runtime environment configured."
}

run_hecras() {
  log "Launching ${RUN_CHOICE}..."
  pushd "${MODEL_DIR}" >/dev/null
  ./"${RUN_CHOICE}" 2>&1 | tee "${LOG_FILE}"
  popd >/dev/null
  log "Run complete. Log written to ${LOG_FILE}"
}

collect_results() {
  local result_dir="${OUTPUT_DIR}/project"
  rm -rf "${result_dir}"
  mkdir -p "${result_dir}"
  cp -a "${MODEL_DIR}/." "${result_dir}/"
  log "Results staged to ${result_dir}"
}

main() {
  [[ -d "${BASE_INSTALL_DIR}" ]] || fail "HEC-RAS payload not found at ${BASE_INSTALL_DIR}"

  prepare_workspace
  link_release_layout
  validate_run_choice
  extract_user_project
  configure_runtime_env
  run_hecras
  collect_results

  log "Workflow completed successfully."
}

main "$@"
