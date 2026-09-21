#!/usr/bin/env bash
# Download every enabled image in the catalog into images/.
# Usage: scripts/fetch.sh [id ...]
#        ALL=1 scripts/fetch.sh      # also download rows marked enabled=no

# shellcheck source=lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

need curl grep sed awk sort

mkdir -p "$IMAGE_DIR" "$CACHE_DIR"
[ "${ALL:-0}" = "1" ] || ONLY_ENABLED=1
export ONLY_ENABLED

manual_list="$CACHE_DIR/manual.txt"
: > "$manual_list"

fetch_one() {
  local id="$1" category="$2" mode="$3" source="$4" pattern="$5" sums="$6" notes="$8"
  local dest_dir="$IMAGE_DIR/$category" url file target

  if [ "$mode" = "manual" ]; then
    printf '%-20s %s\n    %s\n' "$id" "$source" "$notes" >> "$manual_list"
    warn "$id: download it by hand from $source"
    return 0
  fi

  log "$id: looking up the newest file"
  url="$(resolve_url "$mode" "$source" "$pattern")"
  if [ -z "$url" ]; then
    warn "$id: found nothing at $source (the version may have moved - edit config/catalog.tsv)"
    return 1
  fi

  file="$(basename "$url")"
  target="$dest_dir/$file"
  mkdir -p "$dest_dir"

  if [ -s "$target" ]; then
    ok "$id: already here ($file)"
  else
    log "$id: downloading $file"
    curl -fL --retry 3 --retry-delay 5 -C - -o "$target.part" "$url" \
      || { rm -f "$target.part"; warn "$id: download failed"; return 1; }
    mv "$target.part" "$target"
    ok "$id: downloaded $file"
  fi

  if [ "$mode" = "index" ] && [ "$sums" != "-" ]; then
    verify_with_sums "$id" "$target" "${source%/}/$sums" "$file" || return 1
  fi

  unpack_if_zip "$target"
}

# Download the vendor checksum file and compare the line for our file.
verify_with_sums() {
  local id="$1" target="$2" sums_url="$3" file="$4" expected actual
  expected="$(curl -fsSL --max-time 60 "$sums_url" 2>/dev/null | awk -v f="$file" '$2 ~ f || $2 == "*"f {print $1; exit}')"
  if [ -z "$expected" ]; then
    warn "$id: no checksum published for $file - check the vendor page yourself"
    return 0
  fi
  actual="$(sha256_of "$target")"
  if [ "$expected" = "$actual" ]; then
    ok "$id: checksum matches"
  else
    warn "$id: CHECKSUM DOES NOT MATCH. Delete $target and download again."
    return 1
  fi
}

# memtest86+ ships the ISO inside a zip. Ventoy wants the plain ISO, and it
# should keep the version in its name, so the boot menu stays readable.
unpack_if_zip() {
  local target="$1" dir base want tmp count only
  case "$target" in *.zip) ;; *) return 0 ;; esac

  command -v unzip >/dev/null 2>&1 || { warn "unzip is missing - unpack $target yourself"; return 0; }
  dir="$(dirname "$target")"
  base="$(basename "$target")"
  want="${base%.zip}"                 # mt86plus_8.10_x86_64.iso.zip -> ...iso
  tmp="$dir/.unzip.$$"
  rm -rf "$tmp"; mkdir -p "$tmp"

  unzip -o -q -d "$tmp" "$target" || { rm -rf "$tmp"; warn "could not unpack $base"; return 1; }
  count="$(find "$tmp" -type f | wc -l | tr -d ' ')"
  only="$(find "$tmp" -type f | head -1)"

  if [ "$count" = "1" ] && [ "${want##*.}" = "iso" ]; then
    mv "$only" "$dir/$want"           # give it the version in its name
  else
    find "$tmp" -type f -exec mv {} "$dir"/ \;
  fi

  rm -rf "$tmp"
  rm -f "$target"
  ok "unpacked $base"
}

rc=0
if [ "$#" -gt 0 ]; then
  for id in "$@"; do
    row="$(ONLY_ENABLED=0 catalog_rows "$id")"
    [ -n "$row" ] || { warn "no catalog entry called $id"; rc=1; continue; }
    # shellcheck disable=SC2046
    IFS=$'\t' read -r a b c d e f g h <<< "$row"
    fetch_one "$a" "$b" "$c" "$d" "$e" "$f" "$g" "$h" || rc=1
  done
else
  while IFS=$'\t' read -r a b c d e f g h; do
    fetch_one "$a" "$b" "$c" "$d" "$e" "$f" "$g" "$h" || rc=1
  done < <(catalog_rows)
fi

if [ -s "$manual_list" ]; then
  printf '\n%s\n' "Download these by hand, then put them in images/<category>/ :"
  cat "$manual_list"
  printf '%s\n' "See docs/02-manual-downloads.md"
fi

exit "$rc"
