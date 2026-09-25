# Downloads you must do by hand

Some images have no stable link, or a licence that says "click here first".
Download them, then drop the file into `images/<category>/` and run
`make sync DEST=...`.

## Windows 11  ->  `images/windows/`

https://www.microsoft.com/software-download/windows11

Pick "Download Windows 11 Disk Image (ISO)". The file is about 6 GB.
It is bigger than 4 GB, so the stick must be exFAT or NTFS. A Ventoy data
partition is exFAT already, so this just works.

Ventoy skips the Windows 11 hardware check for you: `make sync` writes
`VTOY_WIN11_BYPASS_CHECK` into the boot menu file.

## Hiren's BootCD PE  ->  `images/windows/`

https://www.hirensbootcd.org/download/

A Windows rescue disc. Password reset, disk tools, drivers, file recovery.
About 3 GB.

## SystemRescue  ->  `images/rescue/`

https://www.system-rescue.org/Download/

The single most useful rescue disc: GParted, testdisk, ddrescue, memtest,
network tools. About 900 MB.

## GParted Live  ->  `images/rescue/`

https://gparted.org/download.php

Resize and move partitions with a mouse. About 500 MB.

## Super Grub2 Disk  ->  `images/rescue/`

https://www.supergrubdisk.org/super-grub2-disk/

Starts a computer whose boot loader is broken. Tiny, under 20 MB.

## Kali Linux live  ->  `images/security/`

https://www.kali.org/get-kali/

Open the "Live Boot" tile and take `kali-linux-<version>-live-amd64.iso`.
The mirrors publish only a `.torrent` for this file, so `make fetch` cannot
take it. Any torrent program downloads it. The installer ISO needs no such
work: `make fetch` gets it.

## Tails  ->  `images/security/`

https://tails.net/install/

A live system that forgets everything. Verify the signature on the site
before you trust it.

## FreeDOS  ->  `images/misc/`

https://www.freedos.org/download/

For old BIOS flashing tools that only run under DOS.

## Fedora, Linux Mint and friends

Add them to `config/catalog.tsv` yourself, or just drop the ISO into
`images/linux/`. `make sync` copies anything it finds.
