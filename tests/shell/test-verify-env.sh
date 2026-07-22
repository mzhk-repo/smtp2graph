#!/usr/bin/env bash
# Category 1a: tests the environment contract validator without loading values.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
VALIDATOR="${PROJECT_ROOT}/scripts/verify-env.sh"
TEMP_DIR="$(mktemp -d)"
UNKNOWN_EXAMPLE="${TEMP_DIR}/unknown.env"
MISSING_EXAMPLE="${TEMP_DIR}/missing.env"

cleanup() {
  rm -rf "${TEMP_DIR}"
}

trap cleanup EXIT

expect_failure() {
  local expected_fragment="$1"
  shift
  local output

  if output="$("$@" 2>&1)"; then
    printf 'ERROR: validation unexpectedly succeeded.\n' >&2
    exit 1
  fi
  if [[ "${output}" != *"${expected_fragment}"* ]]; then
    printf 'ERROR: expected validation message was not returned.\n' >&2
    exit 1
  fi
}

cp "${PROJECT_ROOT}/.env.example" "${UNKNOWN_EXAMPLE}"
printf '%s\n' 'UNEXPECTED_KEY=safe-placeholder' >>"${UNKNOWN_EXAMPLE}"
expect_failure 'unknown key in .env.example: UNEXPECTED_KEY.' \
  env VERIFY_ENV_EXAMPLE_FILE="${UNKNOWN_EXAMPLE}" "${VALIDATOR}" --example-only

sed '/^SMTP_LISTEN_PORT=/d' "${PROJECT_ROOT}/.env.example" >"${MISSING_EXAMPLE}"
expect_failure 'required key is missing from .env.example: SMTP_LISTEN_PORT.' \
  env VERIFY_ENV_EXAMPLE_FILE="${MISSING_EXAMPLE}" "${VALIDATOR}" --example-only

printf 'PASS: verify-env rejects unknown and missing keys.\n'
