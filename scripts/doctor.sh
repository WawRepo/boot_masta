#!/usr/bin/env bash
# Is this computer ready? Prints what is missing and which drives it can see.

# shellcheck source=lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

log "system: $(uname -s) $(uname -r) ($(os_name))"

for tool in curl rsync awk sed grep find sort tar; do
  if command -v "$tool" >/dev/null 2>&1; then ok "$tool"; else warn "$tool is MISSING (required)"; fi
done
for tool in unzip python3 shasum sha256sum; do
  command -v "$tool" >/dev/null 2>&1 && ok "$tool (optional)" || warn "$tool is missing (optional)"
done

if [ "$(os_name)" = "linux" ]; then
  command -v mkfs.ext4 >/dev/null 2>&1 && ok "mkfs.ext4 (for persistence)" || warn "mkfs.ext4 is missing - no persistence files"
fi

log "free space where images are kept:"
mkdir -p "$IMAGE_DIR"
df -h "$IMAGE_DIR" | sed 's/^/    /'

log "drives this computer can see:"
case "$(os_name)" in
  macos) diskutil list external physical 2>/dev/null | sed 's/^/    /' || printf '    none\n' ;;
  linux) lsblk -d -o NAME,SIZE,TRAN,MODEL,MOUNTPOINT 2>/dev/null | sed 's/^/    /' ;;
  *)     printf '    unknown system\n' ;;
esac

if [ "$(os_name)" = "macos" ]; then
  printf '\n'
  warn "macOS cannot install Ventoy. Run 'make install-ventoy' to see the two ways around it."
fi
