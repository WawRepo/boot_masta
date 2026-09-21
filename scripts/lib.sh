#!/usr/bin/env bash
# Shared helpers for boot_masta. Source this, do not run it.

set -o errexit
set -o nounset
set -o pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CATALOG="${CATALOG:-$REPO_ROOT/config/catalog.tsv}"
IMAGE_DIR="${IMAGE_DIR:-$REPO_ROOT/images}"
CACHE_DIR="${CACHE_DIR:-$REPO_ROOT/.cache}"

if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  C_RED=$'\033[31m'; C_GRN=$'\033[32m'; C_YEL=$'\033[33m'; C_BLU=$'\033[34m'; C_OFF=$'\033[0m'
else
  C_RED=""; C_GRN=""; C_YEL=""; C_BLU=""; C_OFF=""
fi

log()  { printf '%s==>%s %s\n' "$C_BLU" "$C_OFF" "$*"; }
ok()   { printf '%s  ok%s %s\n' "$C_GRN" "$C_OFF" "$*"; }
warn() { printf '%swarn%s %s\n' "$C_YEL" "$C_OFF" "$*" >&2; }
die()  { printf '%sfail%s %s\n' "$C_RED" "$C_OFF" "$*" >&2; exit 1; }

need() {
  local missing=0 tool
  for tool in "$@"; do
    command -v "$tool" >/dev/null 2>&1 || { warn "missing command: $tool"; missing=1; }
  done
  [ "$missing" -eq 0 ] || die "install the missing commands and try again"
}

os_name() {
  case "$(uname -s)" in
    Darwin) echo macos ;;
    Linux)  echo linux ;;
    *)      echo other ;;
  esac
}

# sha256 of a file, on macOS and Linux.
sha256_of() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  else
    shasum -a 256 "$1" | awk '{print $1}'
  fi
}

# Read the catalog. Prints: id, category, mode, source, pattern, sums, enabled, notes
# $1 (optional) = only this id. Set ONLY_ENABLED=1 to drop disabled rows.
catalog_rows() {
  local want="${1:-}"
  awk -F'\t' -v want="$want" -v only="${ONLY_ENABLED:-0}" '
    /^#/ || NF < 8 { next }
    want != "" && $1 != want { next }
    only == "1" && $7 != "yes" { next }
    { print }
  ' "$CATALOG"
}

# "https://a.b/c/d" -> "https://a.b"
url_origin() { printf '%s\n' "$1" | sed -E 's#^(https?://[^/]+).*#\1#'; }

# Newest matching file in an Apache/nginx style directory listing.
# $1 = directory URL, $2 = file name regex -> prints the file name
resolve_index() {
  local url="$1" pattern="$2"
  curl -fsSL --retry 3 --max-time 60 "$url" \
    | grep -oE "$pattern" \
    | sort -uV \
    | tail -n 1
}

# Newest release asset of a GitHub repo.
# $1 = owner/repo, $2 = asset name regex -> prints the download URL
resolve_github() {
  local repo="$1" pattern="$2"
  curl -fsSL --retry 3 --max-time 60 \
    -H 'Accept: application/vnd.github+json' \
    "https://api.github.com/repos/${repo}/releases/latest" \
    | grep -oE '"browser_download_url": *"[^"]+"' \
    | sed -E 's/.*"(https[^"]+)"/\1/' \
    | grep -E "/${pattern}\$" \
    | sort -uV \
    | tail -n 1
}

# Full download URL for one catalog row. Empty output = nothing to download.
resolve_url() {
  local mode="$1" source="$2" pattern="$3" file
  case "$mode" in
    direct) printf '%s\n' "$source" ;;
    index)
      file="$(resolve_index "$source" "$pattern" || true)"
      [ -n "$file" ] || return 0
      case "$file" in
        http*)  printf '%s\n' "$file" ;;                       # full link on the page
        /*)     printf '%s%s\n' "$(url_origin "$source")" "$file" ;;  # path from the site root
        *)      printf '%s%s\n' "${source%/}/" "$file" ;;      # plain file name in a listing
      esac
      ;;
    github) resolve_github "$source" "$pattern" || true ;;
    manual) return 0 ;;
    *) warn "unknown mode: $mode" ;;
  esac
}

confirm() {
  local answer
  printf '%s [type YES to continue] ' "$1"
  read -r answer
  [ "$answer" = "YES" ] || die "cancelled"
}
