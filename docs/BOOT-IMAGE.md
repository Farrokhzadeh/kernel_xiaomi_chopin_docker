# Boot image packaging

The build creates a kernel, not a universal flashable image. A usable Debian
boot image also contains the installation's initramfs, boot header metadata and
the full Xiaomi MT6893 DTB. Preserve them from the currently working image.

## Before changing anything

Requirements:

- unlocked bootloader
- verified backups of `boot_a`, `boot_b`, `vendor_boot`, `dtbo` and `vbmeta`
- a working recovery/fastboot path independent of the installed system
- MagiskBoot appropriate for the build host (or QEMU user emulation)

Never use `dist/chopin.dtb` in place of the extracted `dtb`. The former is a
small community overlay; the latter is the complete device tree required by
this boot chain.

## Repack with MagiskBoot

Run this in a new empty directory. `boot-original.img` must be a known-working
Debian boot image from the same device installation.

```bash
magiskboot unpack boot-original.img
cp /path/to/this-repo/dist/Image kernel
magiskboot repack boot-original.img boot-chopin-docker.img
```

For an AArch64-only MagiskBoot binary on an x86-64 host, prefix the commands
with `qemu-aarch64-static`.

Unpack the candidate into a second empty directory and compare all components:

```bash
magiskboot unpack boot-chopin-docker.img
sha256sum kernel ramdisk.cpio dtb
cmp kernel /path/to/this-repo/dist/Image
cmp ramdisk.cpio /path/to/original-unpack/ramdisk.cpio
cmp dtb /path/to/original-unpack/dtb
```

Only `kernel` should change. Header version, page size, OS version, command
line, ramdisk and DTB should remain those of the working base image.

## Flashing

Flashing is device-destructive if the image or partition is wrong. Confirm the
device identity and active slot first. The POCO X3 GT layout tested here uses
Android A/B boot partitions, but do not assume another device has the same
layout.

From Windows fastboot, a deliberate two-slot installation is:

```powershell
fastboot devices
fastboot flash boot_a boot-chopin-docker.img
fastboot flash boot_b boot-chopin-docker.img
fastboot reboot
```

Flashing both slots removes the untouched-slot rollback option. Flash one slot
first when rollback matters. Do not flash `Image`, `Image.gz`, `Image.gz-dtb`
or `chopin.dtb` directly to `boot`; only flash the repacked Android boot image.

