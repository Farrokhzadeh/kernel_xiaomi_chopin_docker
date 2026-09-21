#!/usr/bin/env bash

set -Eeuo pipefail
source "$(dirname "$0")/lib.sh"

require_command git

mkdir -p "$WORK_ROOT"

if [[ ! -d "$KERNEL_DIR/.git" ]]; then
    git clone --depth 1 --single-branch --branch "$KERNEL_BRANCH" \
        "$KERNEL_REPO" "$KERNEL_DIR"
fi

actual_commit="$(git -C "$KERNEL_DIR" rev-parse --short="${#KERNEL_COMMIT}" HEAD)"
[[ "$actual_commit" == "$KERNEL_COMMIT" ]] || \
    die "kernel HEAD is $actual_commit; expected $KERNEL_COMMIT"

if [[ ! -x "$TOOLCHAIN_DIR/bin/clang" ]]; then
    git clone --depth 1 --single-branch --branch "$TOOLCHAIN_BRANCH" \
        "$TOOLCHAIN_REPO" "$TOOLCHAIN_DIR"
fi

patch_file="$PROJECT_ROOT/patches/0001-chopin-export-vendor-trace-buffer.patch"
if git -C "$KERNEL_DIR" apply --reverse --check "$patch_file" 2>/dev/null; then
    printf 'Wi-Fi compatibility patch already applied.\n'
else
    git -C "$KERNEL_DIR" apply --check "$patch_file"
    git -C "$KERNEL_DIR" apply "$patch_file"
fi

printf 'Kernel source: %s (%s)\n' "$KERNEL_DIR" "$actual_commit"
printf 'Toolchain:     %s\n' "$TOOLCHAIN_DIR"

