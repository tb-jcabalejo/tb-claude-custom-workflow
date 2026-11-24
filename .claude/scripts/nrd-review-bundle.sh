#!/usr/bin/env bash
# Build the input bundle for /nrd-review. Reads GitHub; writes only under a new temp folder
# (plus a detached worktree registered in a sibling clone, removed by --cleanup).
#
# Usage:
#   nrd-review-bundle.sh <owner/repo> <pr-number> [--sha <commit>] [--workspace <dir>]
#   nrd-review-bundle.sh --local [<base-ref>]
#   nrd-review-bundle.sh --cleanup <root-dir>
#
# Prints KEY=value lines: ROOT, BUNDLE, CHECKOUT, COMPARE, REPO, N, SHA, SHA7, REVIEW_ID, TICKET_KEYS.
set -euo pipefail

die() { echo "nrd-review-bundle: $*" >&2; exit 1; }
need() { command -v "$1" >/dev/null 2>&1 || die "$1 not found on PATH"; }
need git; need jq

MARK='<!-- tb-review:'

ticket_keys() { # title, branch, body → up to 3 unique keys, title first
  local k
  for src in "$@"; do
    printf '%s\n' "$src" | grep -oE '\b[A-Za-z][A-Za-z0-9]{1,9}-[0-9]+\b' | tr '[:lower:]' '[:upper:]' |
      grep -vE '^(UTF|SHA|ISO|RFC|HTTP|TLS|AES|PG|V|X|ES)[0-9]*-' || true
  done | awk '!seen[$0]++' | head -3 | tr '\n' ' '
}

right_lines() { # unified diff → path:line for every RIGHT-side line GitHub can anchor to
  awk '
    /^\+\+\+ \/dev\/null/ { path=""; next }
    /^\+\+\+ b\//         { path=substr($0,7); next }
    /^@@/                 { match($0, /\+[0-9]+/); n=substr($0,RSTART+1,RLENGTH-1)+0; next }
    path=="" || /^\\/     { next }
    /^\+/ || /^ /         { print path ":" n; n++; next }
  ' "$1"
}

write_meta() {
  local f="$1"; shift
  : > "$f"
  for kv in "$@"; do printf '%s=%q\n' "${kv%%=*}" "${kv#*=}" >> "$f"; done
}

if [ "${1:-}" = "--cleanup" ]; then
  root="${2:-}"; [ -f "$root/meta.env" ] || die "no meta.env in '$root'"
  # shellcheck disable=SC1091
  . "$root/meta.env"
  if [ "$CHECKOUT_KIND" = worktree ]; then git -C "$SIBLING" worktree remove --force "$CHECKOUT" 2>/dev/null || true; fi
  rm -rf "$root"
  echo "REMOVED=$root"; exit 0
fi

ROOT="$(mktemp -d "${TMPDIR:-/tmp}/nrd-review.XXXXXX")"
B="$ROOT/bundle"; C="$ROOT/compare"; mkdir -p "$B" "$C"

if [ "${1:-}" = "--local" ]; then
  top="$(git rev-parse --show-toplevel 2>/dev/null)" || die "--local must run inside a git repo"
  REPO="$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || git -C "$top" remote get-url origin | sed -E 's#(\.git)?$##; s#^.*[:/]([^/]+/[^/]+)$#\1#')"
  base="${2:-}"
  if [ -z "$base" ]; then
    def="$(gh repo view --json defaultBranchRef -q .defaultBranchRef.name 2>/dev/null || echo main)"
    base="origin/$def"
  fi
  git -C "$top" rev-parse --verify -q "$base" >/dev/null || die "base ref '$base' not found"
  SHA="$(git -C "$top" rev-parse HEAD)"; branch="$(git -C "$top" branch --show-current)"
  mb="$(git -C "$top" merge-base "$base" HEAD)"
  git -C "$top" diff "$mb" HEAD > "$B/diff.patch"
  log="$(git -C "$top" log --format='- %s%n%b' "$mb"..HEAD)"
  git -C "$top" diff --numstat "$mb" HEAD |
    jq -R -s --arg t "$branch" --arg b "$log" --arg h "$branch" --arg base "$base" --arg sha "$SHA" '
      {title:$t, body:$b, headRefName:$h, baseRefName:$base, headRefOid:$sha,
       files:[split("\n")[] | select(length>0) | split("\t") | {path:.[2], additions:(.[0]|tonumber? // 0), deletions:(.[1]|tonumber? // 0)}]}' > "$B/pr.json"
  [ -z "$(git -C "$top" status --porcelain)" ] || echo "WARNING=uncommitted changes are not reviewed (HEAD only)"
  echo "none" > "$B/prior.md"; echo "none" > "$B/replies.md"
  N=""; REVIEW_ID="$REPO@$branch:$SHA"; CHECKOUT="$top"; KIND=local; SIB=""
  keys="$(ticket_keys "$branch" "$log")"
else
  need gh
  REPO="${1:-}"; N="${2:-}"; shift 2 || true
  [[ "$REPO" =~ ^[^/]+/[^/]+$ ]] && [[ "$N" =~ ^[0-9]+$ ]] || die "usage: <owner/repo> <pr-number> [--sha <commit>] [--workspace <dir>]"
  want_sha=""; ws="$PWD"
  while [ $# -gt 0 ]; do
    case "$1" in
      --sha) want_sha="$2"; shift 2 ;;
      --workspace) ws="$2"; shift 2 ;;
      *) die "unknown option $1" ;;
    esac
  done

  gh pr view "$N" -R "$REPO" --json number,title,body,url,author,headRefName,baseRefName,headRefOid,files > "$B/pr.json"
  base="$(jq -r .baseRefName "$B/pr.json")"; branch="$(jq -r .headRefName "$B/pr.json")"
  SHA="${want_sha:-$(jq -r .headRefOid "$B/pr.json")}"

  # Checkout: detached worktree from a sibling clone if one exists, else a partial clone.
  name="${REPO#*/}"; SIB=""
  for d in "$ws/$name" "$(dirname "$ws")/$name" "$ws"; do
    if [ -d "$d/.git" ] || [ -f "$d/.git" ]; then
      url="$(git -C "$d" remote get-url origin 2>/dev/null || true)"
      if printf '%s' "$url" | grep -qiE "[:/]$REPO(\.git)?$"; then SIB="$d"; break; fi
    fi
  done
  CHECKOUT="$ROOT/checkout"
  if [ -n "$SIB" ]; then
    KIND=worktree
    git -C "$SIB" fetch -q origin "pull/$N/head" "$base"
    git -C "$SIB" worktree add -q --detach "$CHECKOUT" "$SHA"
  else
    KIND=clone
    gh repo clone "$REPO" "$CHECKOUT" -- -q --filter=blob:none --no-checkout
    git -C "$CHECKOUT" fetch -q origin "pull/$N/head" "$base"
    git -C "$CHECKOUT" checkout -q --detach "$SHA"
  fi
  mb="$(git -C "$CHECKOUT" merge-base "origin/$base" "$SHA")"
  git -C "$CHECKOUT" diff "$mb" "$SHA" > "$B/diff.patch"
  files="$(git -C "$CHECKOUT" diff --numstat "$mb" "$SHA" | jq -R -s '[split("\n")[] | select(length>0) | split("\t") | {path:.[2], additions:(.[0]|tonumber? // 0), deletions:(.[1]|tonumber? // 0)}]')"
  jq --argjson f "$files" --arg sha "$SHA" '.files=$f | .headRefOid=$sha' "$B/pr.json" > "$B/pr.json.tmp" && mv "$B/pr.json.tmp" "$B/pr.json"

  # Earlier tb-reviews (prior.md) and replies since the last one (replies.md).
  gh api --paginate "repos/$REPO/pulls/$N/reviews" | jq -s 'add // []' > "$ROOT/reviews.json"
  jq -r --arg m "$MARK" '[.[] | select(.body | contains($m))] | last | .body // "none"' "$ROOT/reviews.json" > "$B/prior.md"
  since="$(jq -r --arg m "$MARK" '[.[] | select(.body | contains($m))] | last | .submitted_at // ""' "$ROOT/reviews.json")"
  if [ -n "$since" ]; then
    { gh api --paginate "repos/$REPO/issues/$N/comments"; gh api --paginate "repos/$REPO/pulls/$N/comments"; } | jq -s 'add // []' |
      jq -r --arg s "$since" '[.[] | select(.created_at > $s and .user.type != "Bot")] | sort_by(.created_at)[] |
        "### \(.user.login) at \(.created_at)\(if .path then " on \(.path):\(.line // .original_line)" else "" end)\n\(.body)\n"' > "$B/replies.md"
    [ -s "$B/replies.md" ] || echo "none" > "$B/replies.md"
  else
    echo "none" > "$B/replies.md"
  fi

  # NRD Sight's own review for --compare. Kept outside the bundle so the reviewer never sees it.
  jq -r --arg sha "$SHA" '
    [.[] | select(.user.login == "nrd-sight[bot]")] as $r
    | (([$r[] | select(.commit_id == $sha)] | last) // ($r | last)) as $x
    | if $x then "<!-- nrd commit: \($x.commit_id) same_sha: \($x.commit_id == $sha) -->\n\($x.body)" else "none" end' \
    "$ROOT/reviews.json" > "$C/nrd-sight.md"

  REVIEW_ID="$REPO#$N:$SHA"
  keys="$(ticket_keys "$(jq -r .title "$B/pr.json")" "$branch" "$(jq -r .body "$B/pr.json")")"
fi

right_lines "$B/diff.patch" > "$ROOT/right-lines.txt"
echo "${keys:-}" > "$B/ticket_keys.txt"
echo "none" > "$B/ticket.md"
write_meta "$ROOT/meta.env" "REPO=$REPO" "N=$N" "SHA=$SHA" "CHECKOUT=$CHECKOUT" "CHECKOUT_KIND=$KIND" "SIBLING=$SIB" "REVIEW_ID=$REVIEW_ID"

cat <<EOF
ROOT=$ROOT
BUNDLE=$B
CHECKOUT=$CHECKOUT
COMPARE=$C/nrd-sight.md
RIGHT_LINES=$ROOT/right-lines.txt
REPO=$REPO
N=$N
SHA=$SHA
SHA7=${SHA:0:7}
REVIEW_ID=$REVIEW_ID
TICKET_KEYS=${keys:-}
FILES_CHANGED=$(jq '.files | length' "$B/pr.json")
DIFF_LINES=$(wc -l < "$B/diff.patch" | tr -d ' ')
EOF
