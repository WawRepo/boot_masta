#!/usr/bin/env bash
# Make a "persistence" file so a live Linux keeps your files after a restart.
# The file is an ext4 disk image. Ventoy hands it to the live system at boot.
#
# Usage (Linux):  sudo scripts/persistence.sh /Volumes/BOOTMASTA ubuntu-24.04.3-desktop-amd64.iso 8G
# macOS cannot make ext4 files. The script says what to do instead.

# shellcheck source=lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

DEST="${1:-}"
ISO="${2:-}"
SIZE="${3:-8G}"

usage() {
  cat <<TXT
usage: sudo $0 <ventoy-mount> <iso file name> [size]
  example: sudo $0 /media/me/BOOTMASTA kali-linux-2025.2-live-amd64.iso 16G

The file lands in <ventoy-mount>/persistence/<iso name without .iso>.dat
Then run 'make menu DEST=<ventoy-mount>' so the boot menu picks it up.
TXT
}

[ -n "$DEST" ] && [ -n "$ISO" ] || { usage; exit 1; }
[ -d "$DEST" ] || die "$DEST is not mounted"

if [ "$(os_name)" != "linux" ]; then
  cat <<'TXT'
Persistence files are ext4. Only Linux can make them.

Do this instead:
  1. Boot the stick, start the live Linux (Ubuntu or Kali).
  2. Open a terminal in the live session.
  3. Mount the big Ventoy partition, then run this same script there.

Ventoy also ships CreatePersistentImg.sh in its Linux package, which does the
same job: https://www.ventoy.net/en/plugin_persistence.html
TXT
  exit 0
fi

[ "$(id -u)" -eq 0 ] || die "run it with sudo"
need mkfs.ext4 dd

label="persistence"          # Ubuntu and Debian look for this label
case "$ISO" in
  kali-*) label="persistence" ;;
esac

dir="$DEST/persistence"
out="$dir/${ISO%.iso}.dat"
mkdir -p "$dir"
[ -e "$out" ] && die "$out already exists - delete it first"

log "making a $SIZE file at $out"
if command -v fallocate >/dev/null 2>&1; then
  fallocate -l "$SIZE" "$out"
else
  dd if=/dev/zero of="$out" bs=1M count="$(( ${SIZE%G} * 1024 ))" status=progress
fi

mkfs.ext4 -F -L "$label" "$out" >/dev/null
ok "formatted as ext4, label=$label"

# Kali needs a persistence.conf inside the file. Ubuntu does not.
case "$ISO" in
  kali-*)
    tmp="$(mktemp -d)"
    mount -o loop "$out" "$tmp"
    printf '/ union\n' > "$tmp/persistence.conf"
    umount "$tmp"; rmdir "$tmp"
    ok "added persistence.conf for Kali"
    ;;
esac

"$REPO_ROOT/scripts/gen-ventoy-json.sh" "$DEST"
ok "done. Boot the ISO and pick the persistence entry in the second menu."
