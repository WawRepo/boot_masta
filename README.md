<h1 align="center"><img src="assets/logo.png" alt="boot_masta" width="600"></h1>

One USB stick. Many systems. Plug it in, start the computer, pick from a menu.

It uses **Ventoy**. Ventoy is a small boot loader you install on the stick once.
After that you only copy `.iso` files onto the stick. No re-flashing, ever.

## What you get on the stick

| Category | What it does |
|---|---|
| `diagnostics/` | Memtest86+ (tests the memory), ShredOS (erases a disk for good) |
| `linux/` | Ubuntu Desktop, Debian, Arch, Proxmox VE - live sessions and installers |
| `security/` | Kali Linux live and installer, Tails |
| `rescue/` | SystemRescue, GParted Live, Clonezilla, Rescuezilla, Super Grub2 |
| `windows/` | Windows 11 installer, Hiren's BootCD PE, a Windows-To-Go `.vhdx` |
| `misc/` | FreeDOS for old firmware tools |

Turn entries on and off in `config/catalog.tsv`.

## Quick start

```bash
make doctor                       # is this computer ready?
make check                        # do all download links still work?
make fetch                        # download the ISOs into images/  (big, slow)
make install-ventoy DEV=/dev/sdX  # Linux only. ERASES the stick.
make sync DEST=/Volumes/BOOTMASTA # copy the ISOs and write the boot menu
```

Then start a PC from the stick. Press `F12`, `F11`, `Esc` or `Del` at power on
to get the boot menu. Turn Secure Boot off if the PC refuses.

## On a Mac

macOS cannot install Ventoy. Everything else works on macOS.
Run `make install-ventoy` and it prints the two ways around it:
the Ventoy LiveCD, or a Linux virtual machine with USB pass-through.
Full steps: [docs/05-macos.md](docs/05-macos.md).

## What runs, what installs

| Goal | How |
|---|---|
| Test the memory | Boot `mt86plus_*.iso`. It runs on its own. |
| Install Ubuntu | Boot the Ubuntu ISO, choose "Install". |
| Run Ubuntu from the stick | Boot the Ubuntu ISO, choose "Try". Add persistence to keep files. |
| Install Windows | Boot the Windows 11 ISO. |
| Run Windows from the stick | A `.vhdx` file plus vtoyboot. See [docs/03-windows-to-go.md](docs/03-windows-to-go.md). |
| Install Kali | Boot the Kali installer ISO. |
| Install Proxmox VE | Boot the Proxmox ISO. It ERASES the target disk. |
| Run Kali from the stick | Boot the Kali live ISO. Persistence works the same way. |
| Rescue a dead PC | SystemRescue, GParted, Clonezilla, Hiren's. |

## Hardware

- 64 GB stick minimum. 128 GB is comfortable. 256 GB if you want Windows-To-Go.
- USB 3.0 or faster, or the wait will hurt.
- An SSD in a USB case beats any flash stick, and Windows-To-Go needs one.

## Repo layout

```
config/catalog.tsv    what to download, and from where. Edit this.
scripts/              one script per job. All of them print what they do.
images/               the downloaded ISOs. Never committed.
docs/                 the long answers.
assets/               logo.png, icon.png, social-preview.png (GitHub link card).
```

## Docs

- [01 - quick start, step by step](docs/01-quickstart.md)
- [02 - the downloads you must do by hand](docs/02-manual-downloads.md)
- [03 - run Windows from the stick](docs/03-windows-to-go.md)
- [04 - keep your files between reboots](docs/04-persistence.md)
- [05 - doing this from a Mac](docs/05-macos.md)
- [06 - when it does not boot](docs/06-troubleshooting.md)
- [07 - licences and the law](docs/07-legal.md)

## Warnings

- `make install-ventoy` **erases the whole stick**. Check the device name twice.
- ShredOS **destroys data** and you cannot get it back.
- Windows needs a licence. This repo does not give you one.
- Only test systems you own or have written permission to test.

## Licence

MIT. See [LICENSE](LICENSE).
