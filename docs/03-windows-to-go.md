# Run Windows from the stick (Windows-To-Go)

Two different things, do not mix them up:

| | Where Windows lives | What you need |
|---|---|---|
| Windows **installer** | ISO on the stick, installs to the PC disk | just copy the ISO, it works |
| Windows **To-Go** | a `.vhdx` file on the stick, runs from the stick | the steps below |

## What it costs you

- A Windows PC to build it on. macOS and Linux cannot make a bootable Windows image.
- 64 GB of space on the stick, 40 GB minimum for the `.vhdx`.
- A fast stick. On a cheap flash stick Windows crawls. Use an SSD in a USB case.
- A Windows licence. Windows-To-Go is a normal Windows install.

## Steps

1. On a Windows PC, get **WinNTSetup** (free).
2. In WinNTSetup, create a new `VHDX`, 40 GB or more, type **dynamic**.
3. Mount the Windows 11 ISO. Point WinNTSetup at `sources\install.wim` inside it.
4. Install into the VHDX. Do not reboot into it.
5. Get **vtoyboot** from https://github.com/ventoy/vtoyboot/releases
6. Unpack vtoyboot **inside the mounted VHDX** and run `vtoyboot.exe` once.
   This adds the driver that lets Windows start from a file on a USB stick.
7. Unmount the VHDX.
8. Copy it to `<ventoy drive>/windows/win11-togo.vhdx`.
9. Boot the stick, pick the VHDX entry.

`make windows-to-go DEST=/Volumes/BOOTMASTA` prints these steps and checks
whether a `.vhdx` is already on the drive.

## First boot

- Slow. Windows installs drivers for that exact PC. Ten minutes is normal.
- Each new PC repeats the driver step once.
- Turn Secure Boot off if the PC refuses to start it.
- Do not pull the stick out while it runs. You will break the file system.

## Cheaper option

If you only need Windows tools and not full Windows, use
**Hiren's BootCD PE** instead. It is a Windows PE ISO, it boots in under a
minute, and it needs no licence dance. It cannot install programs, but it has
password reset, disk cloning, partitioning, file recovery and a browser.
