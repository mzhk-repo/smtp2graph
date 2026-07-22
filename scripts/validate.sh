#!/usr/bin/env bash
# Category 1a: validation only; no production or runtime side effects.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
PRE_COMMIT_BIN="${PRE_COMMIT_BIN:-${PROJECT_ROOT}/.venv/bin/pre-commit}"
PRE_COMMIT_HOME="${PRE_COMMIT_HOME:-${PROJECT_ROOT}/.cache/pre-commit}"

if [[ ! -x "${PRE_COMMIT_BIN}" ]]; then
  printf 'ERROR: pre-commit is unavailable. Run `make bootstrap` first.\n' >&2
  exit 69
fi

export PRE_COMMIT_HOME
cd "${PROJECT_ROOT}"

mapfile -d '' -t repository_files < <(
  git ls-files --cached --others --exclude-standard -z
)

if [[ "${#repository_files[@]}" -eq 0 ]]; then
  printf 'ERROR: repository contains no files to validate.\n' >&2
  exit 66
fi

"${PRE_COMMIT_BIN}" run --files "${repository_files[@]}" --show-diff-on-failure
git diff --check
