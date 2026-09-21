#!/usr/bin/env bash
# Check a Windows-To-Go VHDX on the stick, and print the steps to build one.
# Running Windows FROM the stick needs a .vhdx file plus the vtoyboot driver.
# You must build it on a Windows PC. macOS and Linux cannot.

# shellcheck source=lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

DEST="${1:-${DEST:-}}"

cat <<'TXT'
Windows FROM the USB stick (Windows-To-Go), the Ventoy way
==========================================================

You need: a Windows PC, a Windows 11 ISO, a USB 3.x stick of 64 GB or more.
An SSD in a USB case is much faster and much happier than a flash stick.

  1. On the Windows PC, install WinNTSetup (free).
  2. In WinNTSetup, make a new VHDX file, 40 GB or larger, "dynamic".
  3. Point WinNTSetup at install.wim inside the Windows ISO. Install into the VHDX.
  4. Download vtoyboot from https://github.com/ventoy/vtoyboot/releases
     Unpack it INSIDE the mounted VHDX and run vtoyboot.exe once.
     This adds the driver that lets Windows boot from a file on a USB stick.
  5. Unmount the VHDX. Copy it to  <ventoy drive>/windows/win11-togo.vhdx
  6. Boot the stick and pick the VHDX in the Ventoy menu.

Notes
  - Windows needs its own licence. A Windows-To-Go install is still a Windows install.
  - First boot is slow. It installs drivers for that PC.
  - Turn Secure Boot off, or enrol the Ventoy key, if the PC refuses to start it.
  - This is separate from the Windows INSTALLER ISO, which just works in Ventoy.
TXT

if [ -n "$DEST" ] && [ -d "$DEST" ]; then
  printf '\n'
  found="$(find "$DEST" -maxdepth 2 -iname '*.vhdx' -o -maxdepth 2 -iname '*.vhd' | head -5)"
  if [ -n "$found" ]; then
    ok "found on the drive:"; printf '%s\n' "$found"
  else
    warn "no .vhdx on $DEST yet"
  fi
fi
