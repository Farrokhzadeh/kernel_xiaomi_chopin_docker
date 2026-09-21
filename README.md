# Chopin Docker Kernel

Reproducible Linux 4.14 kernel build for the **POCO X3 GT / Redmi Note 10
Pro 5G** (`chopin`, MediaTek MT6891/MT6893), aimed at Debian 12 and Docker.

> **Thank you to [ChopinKernels](https://github.com/ChopinKernels) for the
> [original Android 12 kernel source](https://github.com/ChopinKernels/kernel_xiaomi_chopin_android_S).**
> This repository is a small build/configuration and compatibility layer on
> top of their work. It does not replace or claim authorship of that source.

The project downloads the pinned upstream source and Proton Clang 13, applies
one vendor Wi-Fi compatibility patch, enables the required container options,
and produces traceable build artifacts. The large kernel tree and proprietary
Xiaomi modules are deliberately not redistributed here.

## What it provides

- Kernel release `4.14.186-ge42bf4992`
- Docker's generally necessary kernel options
- OverlayFS on an F2FS Debian root filesystem
- IPv4/IPv6 NAT, bridge netfilter and basic IPVS support
- cgroup device, pids, CPU bandwidth, block I/O and perf controllers
- legacy cgroup v1 boot mode for Linux 4.14 compatibility
- compatibility exports required by Xiaomi's Android 12 Wi-Fi modules
- reproducible local, GitHub Actions and GitLab CI builds

The tested phone used Xiaomi vendor firmware `V14.0.6.0.TKPMIXM` (Android 12)
and Debian 12. Other vendor releases may expect a different private module ABI.

## Quick build (Debian/Ubuntu)

Install dependencies:

```bash
sudo apt-get update
sudo apt-get install -y \
  bc bison build-essential ca-certificates cpio curl device-tree-compiler \
  flex git libelf-dev libssl-dev python3 rsync xz-utils
```

Build:

```bash
git clone https://github.com/YOUR-NAME/kernel_xiaomi_chopin_docker.git
cd kernel_xiaomi_chopin_docker
make -j"$(nproc)"
```

The wrapper clones its pinned dependencies into `.work/` and writes results to
`dist/`. Override `JOBS`, `WORK_ROOT`, `OUT_DIR` or `DIST_DIR` when needed:

```bash
JOBS=8 WORK_ROOT=/fast-disk/chopin-work ./scripts/build.sh
```

Do **not** put Proton Clang's `bin` directory first in `PATH`. Its old host
linker cannot read modern glibc RELR sections. The script passes target tools
explicitly while leaving host utilities on the host toolchain.

## Build outputs

| File | Purpose |
|---|---|
| `Image` | Raw ARM64 kernel; use this when replacing `kernel` in a boot image |
| `Image.gz` | Compressed kernel |
| `Image.gz-dtb` | Community DTB appended form; not for the tested header-v2 boot image |
| `chopin.dtb` | Community overlay DTB; not a replacement for Xiaomi's full boot DTB |
| `kernel.config` | Effective configuration |
| `Module.symvers` | Exported symbol versions |
| `kernel.release` | Expected `uname -r` |
| `SHA256SUMS` | Artifact integrity hashes |
| `build.log` | Complete compiler output |

CI artifacts are **not directly flashable boot images**. The tested Debian boot
image uses Android boot header v2 with a separate full DTB and a custom
ramdisk. See [Boot image packaging](docs/BOOT-IMAGE.md).

## CI

GitHub Actions builds on pushes, pull requests and manual runs. Download the
result from the workflow's **Artifacts** section.

GitLab can build this project too. `.gitlab-ci.yml` uses an Ubuntu 24.04
container and publishes `dist/` for 14 days. A shared runner needs roughly
20–30 GB free disk, several GB of RAM and up to three hours; runner limits and
clone bandwidth decide whether a specific GitLab plan is sufficient.

## Technical notes

Linux 4.14 lacks the cgroup-v2 device-BPF behavior expected by current runc.
With a unified hierarchy, containers failed at startup with:

```text
bpf_prog_query(BPF_CGROUP_DEVICE) failed: invalid argument
```

The built-in command line appends `systemd.unified_cgroup_hierarchy=0`, causing
systemd to mount the v1 controllers required by Docker. Bootloader arguments
are still retained because `CONFIG_CMDLINE_EXTEND=y` is used.

The Wi-Fi patch restores two Xiaomi/MediaTek private exports used by the vendor
modules. Its layout and cost are documented in
[Wi-Fi compatibility](docs/WIFI-COMPATIBILITY.md).

## Verify a running phone

```bash
uname -r
cat /proc/cmdline
findmnt -t cgroup,cgroup2
cat /proc/modules
sudo docker info
sudo docker run --rm hello-world
```

Expected essentials are release `4.14.186-ge42bf4992`, the legacy-cgroup flag,
v1 controller mounts, and all four connectivity modules loaded.

## Reproducibility and scope

Pinned inputs are in `SOURCE.lock`. The short upstream commit ID is verified
after cloning. `config/docker-required.config` is human-readable documentation;
`scripts/configure.sh` is the executable configuration source of truth, and
`scripts/verify-config.sh` fails if essential options disappear.

This is an enthusiast device kernel, not an official Xiaomi, Debian, Docker or
ChopinKernels release. Keep known-good boot images and an external recovery
path. Unlocking or flashing can erase data or make the device unbootable.

## License and credits

The overlay project is GPL-2.0-only. Downloaded components retain their own
licenses and copyright notices.

- Kernel source: [ChopinKernels/kernel_xiaomi_chopin_android_S](https://github.com/ChopinKernels/kernel_xiaomi_chopin_android_S), branch `S`, commit `e42bf4992`
- Compiler: [Proton Clang](https://gitlab.com/LeCmnGend/proton-clang), branch `clang-13`
- Container config reference: [Moby `check-config.sh`](https://github.com/moby/moby/blob/master/contrib/check-config.sh)

Special thanks again to the ChopinKernels maintainers and contributors: this
work exists because they published the device kernel source.

