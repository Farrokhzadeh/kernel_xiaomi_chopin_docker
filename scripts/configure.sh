#!/usr/bin/env bash

set -Eeuo pipefail
source "$(dirname "$0")/lib.sh"

"$PROJECT_ROOT/scripts/prepare-source.sh"
mkdir -p "$OUT_DIR"

make -C "$KERNEL_DIR" O="$OUT_DIR" ARCH=arm64 "$KERNEL_DEFCONFIG"

"$KERNEL_DIR/scripts/config" --file "$OUT_DIR/.config" \
    --enable SYSVIPC \
    --enable IPC_NS \
    --enable POSIX_MQUEUE \
    --enable CGROUP_DEVICE \
    --enable BRIDGE_NETFILTER \
    --enable NETFILTER_XT_MATCH_ADDRTYPE \
    --enable IP6_NF_NAT \
    --enable IP6_NF_TARGET_MASQUERADE \
    --enable IP_VS \
    --enable IP_VS_NFCT \
    --enable IP_VS_PROTO_TCP \
    --enable IP_VS_PROTO_UDP \
    --enable IP_VS_RR \
    --enable NETFILTER_XT_MATCH_IPVS \
    --enable CGROUP_PIDS \
    --enable CFS_BANDWIDTH \
    --enable BLK_CGROUP \
    --enable BLK_DEV_THROTTLING \
    --enable CGROUP_PERF \
    --set-str CMDLINE 'systemd.unified_cgroup_hierarchy=0' \
    --enable CMDLINE_EXTEND \
    --disable CMDLINE_FORCE \
    --disable LOCALVERSION_AUTO

make -C "$KERNEL_DIR" O="$OUT_DIR" ARCH=arm64 olddefconfig
"$PROJECT_ROOT/scripts/verify-config.sh" "$OUT_DIR/.config"

