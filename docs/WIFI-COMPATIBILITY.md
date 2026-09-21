# Xiaomi vendor Wi-Fi compatibility

The Debian installation reuses Xiaomi's Android 12 vendor modules:

- `conninfra.ko`
- `connfem.ko`
- `wmt_chrdev_wifi.ko`
- `wlan_drv_gen4m.ko`

The community kernel source does not export two private symbols expected by
`wmt_chrdev_wifi.ko`: `trace_idx` and `trace_array`. Without them, module
loading stops with `Unknown symbol` and no WLAN interface appears.

`patches/0001-chopin-export-vendor-trace-buffer.patch` restores that vendor ABI.
The types and dimensions were derived from the module's AArch64 references:

- `trace_idx`: 32-bit index
- 40,960 ring entries
- 536 bytes per entry
- 21,954,560 bytes total, aligned to 8 bytes

This intentionally reserves about 21 MiB of kernel BSS. It is a compatibility
shim for the matching Xiaomi vendor image, not a general upstream interface.
On a working boot, all four modules load. Android vendor modules can still be
marked forced/out-of-tree and taint the kernel; that warning is expected.
