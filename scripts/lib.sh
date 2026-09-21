#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../SOURCE.lock
source "$PROJECT_ROOT/SOURCE.lock"

WORK_ROOT="${WORK_ROOT:-$PROJECT_ROOT/.work}"
KERNEL_DIR="${KERNEL_DIR:-$WORK_ROOT/kernel}"
TOOLCHAIN_DIR="${TOOLCHAIN_DIR:-$WORK_ROOT/proton-clang-13}"
OUT_DIR="${OUT_DIR:-$WORK_ROOT/out}"
DIST_DIR="${DIST_DIR:-$PROJECT_ROOT/dist}"
JOBS="${JOBS:-$(nproc)}"

export ARCH=arm64
export LC_ALL=C

die() {
    printf 'error: %s\n' "$*" >&2
    exit 1
}

require_command() {
    command -v "$1" >/dev/null 2>&1 || die "required command not found: $1"
}

