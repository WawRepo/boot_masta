#!/usr/bin/env bash
# Copy images/ onto the Ventoy drive and write the boot menu.
# Usage: scripts/sync.sh /Volumes/BOOTMASTA
#        DELETE=1 scripts/sync.sh /Volumes/BOOTMASTA   # also remove images that left images/

# shellcheck source=lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

DEST="${1:-${DEST:-}}"
[ -n "$DEST" ] || die "usage: $0 /path/to/ventoy/drive"
[ -d "$DEST" ] || die "$DEST is not mounted"
[ -w "$DEST" ] || die "$DEST is not writable"

# A Ventoy data partition is exFAT and has no 4 GB file limit, but a plain
# FAT32 stick does. Warn early, because Windows ISOs are bigger than 4 GB.
big="$(find "$IMAGE_DIR" -type f -size +4G 2>/dev/null | head -1 || true)"
if [ -n "$big" ]; then
  fs="$(df -T "$DEST" 2>/dev/null | awk 'NR==2{print $2}' || true)"
  [ -n "$fs" ] || fs="$(df "$DEST" | awk 'NR==2{print $1}')"
  log "note: $(basename "$big") is bigger than 4 GB. The drive must be exFAT or NTFS, not FAT32. ($fs)"
fi

need rsync
opts=(-a --info=progress2 --human-readable --partial
      --exclude '.keep' --exclude '*.md' --exclude '.DS_Store' --exclude '*.part')
[ "${DELETE:-0}" = "1" ] && opts+=(--delete)

log "copying images to $DEST"
rsync "${opts[@]}" "$IMAGE_DIR"/ "$DEST"/

log "writing the boot menu"
"$REPO_ROOT/scripts/gen-ventoy-json.sh" "$DEST"

log "flushing the write cache - do not pull the stick yet"
sync
ok "done. Eject the drive, then boot a PC from it."
