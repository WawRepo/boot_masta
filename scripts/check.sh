#!/usr/bin/env bash
# Tell me which catalog rows still resolve to a real file.
# Nothing is downloaded. Run this before a long fetch.

# shellcheck source=lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
need curl grep sed awk sort

printf '%-20s %-12s %-8s %s\n' ID CATEGORY STATE FILE
printf '%s\n' "----------------------------------------------------------------------"

rc=0
while IFS=$'\t' read -r id category mode source pattern sums enabled notes; do
  if [ "$mode" = "manual" ]; then
    printf '%-20s %-12s %-8s %s\n' "$id" "$category" "manual" "$source"
    continue
  fi
  url="$(resolve_url "$mode" "$source" "$pattern" || true)"
  if [ -z "$url" ]; then
    printf '%-20s %-12s %-8s %s\n' "$id" "$category" "STALE" "$source"
    rc=1
  else
    printf '%-20s %-12s %-8s %s\n' "$id" "$category" "ok" "$(basename "$url")"
  fi
done < <(ONLY_ENABLED=0 catalog_rows)

[ "$rc" -eq 0 ] || printf '\n%s\n' "STALE rows need a new source URL in config/catalog.tsv."
exit "$rc"
