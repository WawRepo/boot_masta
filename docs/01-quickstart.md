# Quick start

## 0. What you need

- A USB stick, 64 GB or more, USB 3.0 or faster.
- A computer with `bash`, `curl` and `rsync`. macOS and Linux both have them.
- Free disk space equal to the size of the ISOs you pick. 30-60 GB is normal.

## 1. Check the computer

```bash
make doctor
```

It lists missing commands and the drives it can see.

## 2. Pick what goes on the stick

Open `config/catalog.tsv`. Column 7 is `enabled`. Set `yes` or `no`.
Nothing else in that file needs to change unless a link dies.

```bash
make list    # what is in the catalog
make check   # do the links still work? downloads nothing
```

If a row says `STALE`, the vendor moved the file. Fix the `source` column.

## 3. Download

```bash
make fetch              # every row marked yes
make fetch ID=kali-live # or just one
```

Downloads resume if they break. Checksums are checked when the vendor
publishes them. Rows marked `manual` are printed at the end - you fetch
those yourself, see [02-manual-downloads.md](02-manual-downloads.md).

## 4. Put Ventoy on the stick

**This erases the stick.**

```bash
sudo make install-ventoy DEV=/dev/sdX   # Linux
make install-ventoy                     # macOS: prints the two ways around it
```

Ventoy makes two partitions:
- a tiny boot partition, hidden, leave it alone
- a big exFAT data partition, labelled `BOOTMASTA`, for your ISOs

## 5. Copy the ISOs

```bash
make sync DEST=/Volumes/BOOTMASTA       # macOS
make sync DEST=/media/you/BOOTMASTA     # Linux
```

This copies `images/` onto the stick and writes `ventoy/ventoy.json`,
the file that gives each entry a friendly name in the boot menu.

## 6. Boot it

1. Put the stick in the target PC.
2. Power on, then tap the boot-menu key: `F12` on most, `F11`, `Esc` or `Del` on others.
3. Pick the USB device.
4. The Ventoy menu appears. Arrow keys, then Enter.

If the PC skips the stick, see [06-troubleshooting.md](06-troubleshooting.md).

## 7. Later, add or remove ISOs

Drop a new `.iso` into `images/<category>/` and run `make sync DEST=...` again.
You never re-install Ventoy.
