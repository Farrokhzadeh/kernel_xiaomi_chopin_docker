#!/usr/bin/env bash

set -Eeuo pipefail
source "$(dirname "$0")/lib.sh"

"$PROJECT_ROOT/scripts/configure.sh"
mkdir -p "$DIST_DIR"

build_args=(
    -C "$KERNEL_DIR"
    -j"$JOBS"
    O="$OUT_DIR"
    ARCH=arm64
    LOCALVERSION=
    CC="$TOOLCHAIN_DIR/bin/clang"
    CLANG_TRIPLE=aarch64-linux-gnu-
    CROSS_COMPILE="$TOOLCHAIN_DIR/bin/aarch64-linux-gnu-"
    CROSS_COMPILE_ARM32="$TOOLCHAIN_DIR/bin/arm-linux-gnueabi-"
    LD="$TOOLCHAIN_DIR/bin/ld.lld"
    STRIP="$TOOLCHAIN_DIR/bin/llvm-strip"
    AS="$TOOLCHAIN_DIR/bin/llvm-as"
)

# Do not prepend the old toolchain to PATH: its host ld cannot read modern
# glibc RELR sections. Explicit target-tool paths keep HOSTCC on the host.
set -o pipefail
make "${build_args[@]}" 2>&1 | tee "$DIST_DIR/build.log"

boot_dir="$OUT_DIR/arch/arm64/boot"
cp -a "$boot_dir/Image" "$DIST_DIR/Image"
cp -a "$boot_dir/Image.gz" "$DIST_DIR/Image.gz"
cp -a "$boot_dir/Image.gz-dtb" "$DIST_DIR/Image.gz-dtb"
cp -a "$boot_dir/dts/mediatek/chopin.dtb" "$DIST_DIR/chopin.dtb"
cp -a "$OUT_DIR/.config" "$DIST_DIR/kernel.config"
cp -a "$OUT_DIR/Module.symvers" "$DIST_DIR/Module.symvers"

make -s "${build_args[@]}" kernelrelease > "$DIST_DIR/kernel.release"
(
    cd "$DIST_DIR"
    sha256sum Image Image.gz Image.gz-dtb chopin.dtb kernel.config \
        Module.symvers kernel.release > SHA256SUMS
)

printf 'Build complete: %s\n' "$DIST_DIR"
