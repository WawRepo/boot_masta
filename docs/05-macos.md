# Doing this from a Mac

Short version: a Mac can download, organise and copy. It cannot make the
stick bootable. One Linux session, once, fixes that forever.

## What works on macOS

```bash
make doctor      # yes
make check       # yes
make fetch       # yes
make verify      # yes
make sync        # yes, once the stick already has Ventoy
make menu        # yes
```

## What does not

- `make install-ventoy` - Ventoy has no macOS installer.
- `make persistence` - macOS cannot format ext4.

## Way 1: the Ventoy LiveCD (easiest)

1. Download `ventoy-x.y.z-livecd.iso` from
   https://github.com/ventoy/Ventoy/releases
2. Write it to a **spare small** USB stick:
   ```bash
   diskutil list                       # find the disk number, e.g. disk4
   diskutil unmountDisk /dev/disk4
   sudo dd if=ventoy-livecd.iso of=/dev/rdisk4 bs=4m
   diskutil eject /dev/disk4
   ```
   `rdisk` not `disk`. It is much faster.
3. Boot any PC from that small stick.
4. Plug the big stick in, run Ventoy2Disk, install to the big stick.
5. Back on the Mac: `make sync DEST=/Volumes/BOOTMASTA`.

## Way 2: a Linux virtual machine

UTM (free) or VMware Fusion, plus any Linux live ISO.
Pass the USB stick through to the guest, then run
`sudo scripts/install-ventoy.sh /dev/sdX` inside it.

Apple Silicon note: UTM must emulate x86 for this, which is slow but fine
for a one-off install. Or use Way 1.

## Mounting the stick on macOS

After Ventoy is installed the big partition shows up in Finder as
`/Volumes/BOOTMASTA`. macOS reads and writes exFAT out of the box.

Always eject properly, or the last file will be half written:

```bash
diskutil eject /Volumes/BOOTMASTA
```
