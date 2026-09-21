#!/usr/bin/env bash

set -Eeuo pipefail

config="${1:-}"
[[ -f "$config" ]] || {
    printf 'usage: %s path/to/.config\n' "$0" >&2
    exit 2
}

required_y=(
    SYSVIPC IPC_NS POSIX_MQUEUE CGROUP_DEVICE BRIDGE_NETFILTER
    NETFILTER_XT_MATCH_ADDRTYPE IP6_NF_NAT IP6_NF_TARGET_MASQUERADE
    IP_VS IP_VS_NFCT IP_VS_PROTO_TCP IP_VS_PROTO_UDP IP_VS_RR
    NETFILTER_XT_MATCH_IPVS CGROUP_PIDS CFS_BANDWIDTH BLK_CGROUP
    BLK_DEV_THROTTLING CGROUP_PERF OVERLAY_FS F2FS_FS BLK_DEV_DM
    DM_CRYPT DM_VERITY
)

failed=0
for symbol in "${required_y[@]}"; do
    if ! grep -qx "CONFIG_${symbol}=y" "$config"; then
        printf 'missing: CONFIG_%s=y\n' "$symbol" >&2
        failed=1
    fi
done

grep -qx 'CONFIG_CMDLINE="systemd.unified_cgroup_hierarchy=0"' "$config" || {
    printf 'missing: legacy cgroup command line\n' >&2
    failed=1
}
grep -qx 'CONFIG_CMDLINE_EXTEND=y' "$config" || {
    printf 'missing: CONFIG_CMDLINE_EXTEND=y\n' >&2
    failed=1
}

(( failed == 0 )) || exit 1
printf 'Kernel configuration verification passed.\n'

