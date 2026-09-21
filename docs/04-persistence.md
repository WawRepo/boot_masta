# Keep your files between reboots

A live Linux forgets everything at power off. "Persistence" fixes that:
Ventoy hands the live system a file on the stick, and the system treats it
as a writeable disk.

Works with: Ubuntu, Debian live, Kali live, Mint. Not with: Windows,
Memtest, most rescue discs.

## Make one (Linux only)

```bash
sudo make persistence DEST=/media/you/BOOTMASTA \
     ISO=kali-linux-2026.2-live-amd64.iso SIZE=16G
```

It creates `<drive>/persistence/kali-linux-2026.2-live-amd64.dat`,
formats it as ext4, adds Kali's `persistence.conf` when needed, and rewrites
the boot menu so the ISO and the file are linked.

## On macOS

macOS cannot format ext4. Do this instead:

1. Boot the stick and start the live Ubuntu or Kali.
2. Open a terminal in the live session.
3. Mount the big Ventoy partition.
4. Run the same command there.

## Using it

At boot, pick the ISO. Ventoy shows a second small menu.
Choose the entry that mentions persistence. Your files now survive a restart.

## Size

| Use | Size |
|---|---|
| notes and a few files | 4 GB |
| normal daily use | 8-16 GB |
| Kali with extra tools installed | 32 GB |

The file is made at full size at once. It does not grow later.

## Careful

- One `.dat` file per ISO. Do not share one between two systems.
- Update the ISO to a new version and the old `.dat` no longer matches it.
  Rename the `.dat` to match the new ISO name, or start a fresh one.
- The `.dat` is not encrypted. Anyone with the stick can read it.
