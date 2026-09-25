#!/usr/bin/env bash
# Write <DEST>/ventoy/ventoy.json : menu names, timeout, persistence links.
# Usage: scripts/gen-ventoy-json.sh /Volumes/BOOTMASTA

# shellcheck source=lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

DEST="${1:-${DEST:-}}"
[ -n "$DEST" ] || die "usage: $0 /path/to/ventoy/drive"
[ -d "$DEST" ] || die "$DEST is not a folder"

MENU_TIMEOUT="${MENU_TIMEOUT:-10}"
out_dir="$DEST/ventoy"
out="$out_dir/ventoy.json"
mkdir -p "$out_dir"

# Pretty name for a file, taken from the catalog notes when we can match it.
nice_name() {
  local base="$1"
  case "$base" in
    ubuntu-*-desktop-*)      echo "Ubuntu Desktop - try it live or install it" ;;
    ubuntu-*-live-server-*)  echo "Ubuntu Server - installer" ;;
    debian-*-netinst*)       echo "Debian - small installer" ;;
    kali-*-live-*)           echo "Kali Linux - live session" ;;
    kali-*-installer-*)      echo "Kali Linux - installer" ;;
    archlinux-*)             echo "Arch Linux - installer (expert)" ;;
    proxmox-ve_*)            echo "Proxmox VE - installer (virtual machine server)" ;;
    clonezilla-*)            echo "Clonezilla - clone and image disks" ;;
    mt86plus_*|memtest*)     echo "Memtest86+ - test the memory" ;;
    systemrescue*)           echo "SystemRescue - repair toolkit" ;;
    gparted*)                echo "GParted Live - edit partitions" ;;
    rescuezilla*)            echo "Rescuezilla - backup and restore" ;;
    shredos*)                echo "ShredOS - ERASE a disk for good" ;;
    *Win11*|*win11*|*Windows*|*windows*) echo "Windows 11 - installer" ;;
    HBCD*|hbcd*)             echo "Hirens BootCD PE - Windows rescue tools" ;;
    tails-*)                 echo "Tails - private live system" ;;
    *)                       echo "${base%.*}" ;;
  esac
}

# macOS puts .Spotlight-V100 and .fseventsd on the drive and locks them, so
# skip those folders. Without -prune, find stops with "Operation not permitted".
images="$(cd "$DEST" && find . \
            \( -name '.Spotlight-V100' -o -name '.fseventsd' -o -name '.Trashes' \
               -o -path './ventoy' -o -path './persistence' \) -prune -o \
            -type f ! -name '._*' \( -iname '*.iso' -o -iname '*.img' -o -iname '*.vhd' -o -iname '*.vhdx' -o -iname '*.wim' \) \
            -print 2>/dev/null | sed 's|^\.||' | sort)"

[ -n "$images" ] || warn "no images found under $DEST - the menu will be empty"

{
  printf '{\n'
  printf '  "control": [\n'
  printf '    { "VTOY_MENU_TIMEOUT": "%s" },\n' "$MENU_TIMEOUT"
  printf '    { "VTOY_DEFAULT_MENU_MODE": "0" },\n'
  printf '    { "VTOY_TREE_VIEW_MENU_STYLE": "0" },\n'
  printf '    { "VTOY_FILE_FLT_VTOY": "1" },\n'
  printf '    { "VTOY_SECONDARY_BOOT_MENU": "1" }\n'
  printf '  ],\n'

  printf '  "menu_alias": [\n'
  first=1
  while IFS= read -r img; do
    [ -n "$img" ] || continue
    base="$(basename "$img")"
    [ "$first" -eq 1 ] || printf ',\n'
    first=0
    printf '    { "image": "%s", "alias": "%s" }' "$img" "$(nice_name "$base")"
  done <<< "$images"
  printf '\n  ]'

  # Persistence: link an image to a .dat file of the same name, if it exists.
  persist=""
  while IFS= read -r img; do
    [ -n "$img" ] || continue
    base="$(basename "$img")"
    case "$base" in
      ubuntu-*desktop*|kali-*live*|debian-*live*) ;;
      *) continue ;;
    esac
    dat="/persistence/${base%.iso}.dat"
    [ -f "$DEST$dat" ] || continue
    persist="${persist}    { \"image\": \"$img\", \"backend\": [\"$dat\"] },"$'\n'
  done <<< "$images"

  if [ -n "$persist" ]; then
    printf ',\n  "persistence": [\n%s  ]' "${persist%,$'\n'}"$'\n'
  fi

  printf '\n}\n'
} > "$out"

ok "wrote $out"
if command -v python3 >/dev/null 2>&1; then
  python3 -c 'import json,sys; json.load(open(sys.argv[1]))' "$out" && ok "the JSON is valid"
fi
