# MEGAcmd FUSE on Chopin Debian

This kernel enables built-in `CONFIG_FUSE_FS=y` so that applications such
as MEGAcmd can expose cloud folders through FUSE. The kernel option **alone**
does not create `/dev/fuse` or grant a process permission to mount.

## Verify on the phone (after booting the updated kernel)

Run these commands in the Debian environment where MEGAcmd will run:

```sh
uname -r
grep -w fuse /proc/filesystems
ls -l /dev/fuse
test -c /dev/fuse && echo "/dev/fuse is a character device"
```

FUSE should appear in `/proc/filesystems` and `/dev/fuse` should be a
character device. If they are missing or mounting fails with "permission
denied", examine the Debian/container environment and mount privileges before
assuming the kernel configuration is wrong. Containers may need the FUSE device
explicitly passed through and mount privileges; **do not** run unrelated
workloads as privileged containers merely to test this feature.

## MEGA mount example

Install a compatible version of MEGAcmd with FUSE support and set up your
MEGA session first. Make sure the `/Backups` folder exists in MEGA.

```sh
mkdir -p "$HOME/mega"
mega-fuse-add "$HOME/mega" /Backups
mega-fuse-show
```

You can copy backups into `$HOME/mega` after the mount is active. MEGA FUSE
uploads can be asynchronous: files are **not safely backed up** merely because
a copy command has completed. Keep originals until transfers have completed
and the files have been independently verified in the MEGA cloud.

MEGAcmd's FUSE functionality is beta and uses local disk space for its cache.
Check free disk space, especially for large backups. A FUSE cloud mount is not
a substitute for independent or versioned backup retention.

Official MEGAcmd documentation:
https://github.com/meganz/MEGAcmd/blob/master/contrib/docs/FUSE.md

## CI and installation boundary

CI verifies `CONFIG_FUSE_FS=y` in the built kernel configuration and that
the kernel image and checksums exist. It **cannot** test the running
`/dev/fuse`, actual MEGA uploads, or device boot compatibility.

Build artifacts are raw kernel files, **not** flashable Android boot images.
When updating the phone, keep a working boot image and follow
[BOOT-IMAGE.md](BOOT-IMAGE.md) for repacking and recovery precautions.
