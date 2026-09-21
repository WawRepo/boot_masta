#!/usr/bin/env bash
# Check every file in images/ : size, sha256, and a record of what you had before.
# First run writes config/checksums.local.tsv. Later runs shout if a file changed.

# shellcheck source=lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
need awk find

RECORD="$REPO_ROOT/config/checksums.local.tsv"
[ -f "$RECORD" ] || printf '# sha256\tsize_bytes\tpath\n' > "$RECORD"

rc=0
found=0
while IFS= read -r file; do
  found=1
  rel="${file#"$IMAGE_DIR"/}"
  size="$(wc -c < "$file" | tr -d ' ')"
  log "hashing $rel ($(( size / 1024 / 1024 )) MB)"
  hash="$(sha256_of "$file")"
  known="$(awk -F'\t' -v p="$rel" '$3 == p {print $1; exit}' "$RECORD")"
  if [ -z "$known" ]; then
    printf '%s\t%s\t%s\n' "$hash" "$size" "$rel" >> "$RECORD"
    ok "$rel recorded"
  elif [ "$known" = "$hash" ]; then
    ok "$rel unchanged"
  else
    warn "$rel CHANGED since it was recorded. Download it again."
    rc=1
  fi
done < <(find "$IMAGE_DIR" -type f \( -name '*.iso' -o -name '*.img' -o -name '*.vhd' -o -name '*.vhdx' -o -name '*.wim' \) | sort)

[ "$found" -eq 1 ] || warn "images/ is empty - run 'make fetch' first"
exit "$rc"
