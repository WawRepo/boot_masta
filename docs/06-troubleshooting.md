# When it does not boot

Work down the list. Stop when it starts.

## The PC ignores the stick

1. Tap the right key at power on: `F12` on most, `F11` on some, `Esc` on HP,
   `F9` on some HP, `Del` for the BIOS setup.
2. In BIOS setup, turn **Secure Boot** off. Ventoy can work with it on, but
   off is one less thing to fight.
3. Turn **Fast Boot** off. It skips USB devices.
4. Set USB above the internal disk in the boot order.
5. Try a different USB port. Prefer a port on the back of a desktop, and a
   USB 2.0 port on a stubborn old machine.

## Ventoy starts but the list is empty

- The ISOs must be on the **big data partition**, not the tiny boot one.
- Ventoy looks for `.iso`, `.img`, `.vhd`, `.vhdx`, `.wim`, `.efi`.
  A file named `ubuntu.iso.download` is invisible to it.
- Deep folders are fine. `linux/ubuntu.iso` works.

## An ISO starts, then freezes or shows a black screen

- Put the cursor on the ISO and press `Enter`. A second menu opens. Pick
  **Boot in grub2 mode** (Linux) or **Boot in wimboot mode** (Windows).
  The keys `Ctrl+r` and `Ctrl+w` do the same from the main menu.
- Some ISOs need **Compatible Mode**. Press `Ctrl+i` on the ISO, then `Enter`.
- Re-download the ISO. Run `make verify`. A broken byte gives exactly this.

## "Secure Boot violation"

Turn Secure Boot off, or enrol Ventoy's key when it offers to at first boot.

## Windows 11 says the PC is not supported

`make sync` and `make menu` write `VTOY_WIN11_BYPASS_CHECK` into the boot
menu file, so Ventoy skips the TPM and CPU check for you. If you wrote the
menu some other way, press `F5` at the Ventoy menu, open
**Temporary Control Settings** and turn on the Windows 11 bypass.

## Proxmox VE says it cannot find the installation media

At the Ventoy menu put the cursor on the Proxmox ISO and press `Enter`.
In the second menu pick **Boot in grub2 mode** (or press `Ctrl+r` on the
ISO). That starts it in grub2 mode, which loads the ISO a different way. Normal mode
fails on some machines.

## Files bigger than 4 GB will not copy

The partition is FAT32. A Ventoy data partition is exFAT and has no such
limit. If yours is FAT32, re-install Ventoy without the FAT32 option.

## The stick is slow

- Cheap flash sticks write at 10 MB/s. A 6 GB Windows ISO takes 10 minutes.
- USB 2.0 caps at about 35 MB/s no matter how good the stick is.
- Buy an SSD in a USB case. It is the single biggest change you can make.

## Sanity check

```bash
make verify                 # every file still matches its recorded hash
make menu DEST=/Volumes/BOOTMASTA   # rewrite the boot menu
```

## Still stuck

Ventoy's own list of known ISO problems:
https://www.ventoy.net/en/faq.html
