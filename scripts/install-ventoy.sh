#!/usr/bin/env bash
# Put Ventoy on a USB drive. This ERASES the whole drive.
#
# Linux:   sudo scripts/install-ventoy.sh /dev/sdX
# macOS:   not possible directly - the script prints the two ways that work.
#
# Ventoy makes the stick bootable once. After that you only copy ISO files onto it.

# shellcheck source=lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

VENTOY_DIR="$CACHE_DIR/ventoy"

macos_help() {
  cat <<'TXT'
Ventoy has no macOS installer. Two ways that work:

  1. Ventoy LiveCD (easiest)
     - Download ventoy-x.y.z-livecd.iso from https://github.com/ventoy/Ventoy/releases
     - Write it to a SPARE small USB stick with Balena Etcher or:
         sudo dd if=ventoy-livecd.iso of=/dev/rdiskN bs=4m
     - Boot a PC from that stick, plug in your big stick, run Ventoy2Disk there.

  2. Linux virtual machine with USB pass-through
     - UTM (free) or VMware Fusion, any Linux live ISO.
     - Pass the USB stick to the guest, then run this same script inside it.

After the stick has Ventoy on it, everything else in this repo works on macOS:
  make fetch    # download the ISOs
  make sync DEST=/Volumes/BOOTMASTA
TXT
}

main() {
  if [ "$(os_name)" = "macos" ]; then
    macos_help
    exit 0
  fi

  [ "$(os_name)" = "linux" ] || die "this script supports Linux only"
  [ "$(id -u)" -eq 0 ] || die "run it with sudo"
  need curl tar lsblk

  local device="${1:-}"
  if [ -z "$device" ]; then
    printf '%s\n' "Which disk? Pick the USB stick, not your system disk:"
    lsblk -d -o NAME,SIZE,TRAN,MODEL
    die "usage: sudo $0 /dev/sdX"
  fi
  [ -b "$device" ] || die "$device is not a block device"

  printf '\n'
  lsblk -o NAME,SIZE,TRAN,MODEL,MOUNTPOINT "$device" || true
  printf '\n'
  confirm "This ERASES EVERYTHING on $device."

  mkdir -p "$VENTOY_DIR"
  if [ ! -x "$VENTOY_DIR/Ventoy2Disk.sh" ]; then
    log "downloading the newest Ventoy"
    local url
    url="$(resolve_github ventoy/Ventoy 'ventoy-[0-9.]+-linux\.tar\.gz')"
    [ -n "$url" ] || die "could not find the Ventoy download - get it from https://github.com/ventoy/Ventoy/releases"
    curl -fL --retry 3 -o "$CACHE_DIR/ventoy.tar.gz" "$url"
    tar -xzf "$CACHE_DIR/ventoy.tar.gz" -C "$CACHE_DIR"
    local dir
    dir="$(find "$CACHE_DIR" -maxdepth 1 -type d -name 'ventoy-*' | sort -V | tail -1)"
    rm -rf "$VENTOY_DIR"
    mv "$dir" "$VENTOY_DIR"
  fi

  # -I = force install, -g = GPT (works with UEFI and most BIOS), -L = volume label
  log "installing Ventoy on $device"
  ( cd "$VENTOY_DIR" && sh Ventoy2Disk.sh -I -g -L BOOTMASTA "$device" )

  ok "Ventoy is installed."
  printf '%s\n' "Now: mount the big data partition and run  make sync DEST=/path/to/mount"
}

main "$@"
