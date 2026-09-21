#!/usr/bin/env bash
# Show the catalog and what is already downloaded.

# shellcheck source=lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

printf '%-20s %-12s %-7s %s\n' ID CATEGORY MODE NOTES
printf '%s\n' "--------------------------------------------------------------------------------"
while IFS=$'\t' read -r id category mode source pattern sums enabled notes; do
  [ "$enabled" = "yes" ] || id="$id (off)"
  printf '%-20s %-12s %-7s %s\n' "$id" "$category" "$mode" "$notes"
done < <(ONLY_ENABLED=0 catalog_rows)

printf '\n%s\n' "Files in images/ :"
if [ -d "$IMAGE_DIR" ]; then
  total=0
  while IFS= read -r f; do
    size="$(wc -c < "$f" | tr -d ' ')"
    total=$(( total + size ))
    printf '  %6s MB  %s\n' "$(( size / 1024 / 1024 ))" "${f#"$IMAGE_DIR"/}"
  done < <(find "$IMAGE_DIR" -type f \( -iname '*.iso' -o -iname '*.img' -o -iname '*.vhd' -o -iname '*.vhdx' -o -iname '*.wim' \) | sort)
  printf '  %6s MB  TOTAL\n' "$(( total / 1024 / 1024 ))"
fi
