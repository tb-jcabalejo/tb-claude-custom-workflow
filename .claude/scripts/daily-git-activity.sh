#!/usr/bin/env bash
# Prints my git activity (commits, pushes, current WIP) across local repos for /daily-report.
# Reads local refs and reflogs only; never fetches, so pushes from other machines are not seen.
#
# Usage: daily-git-activity.sh [--since "<git date>"] [--until "<git date>"]
#   --since  default "24 hours ago"; any git date ("2026-11-20 18:00", "3 days ago")
#   --until  default "now"
# Repos: every git repo one level under each root in DAILY_REPORT_ROOTS (colon-separated).
#        Default: the workspace root holding this .claude/ folder, or ~/Documents/TicketBoat
#        when .claude/ is installed in $HOME.
set -uo pipefail

since="24 hours ago"
until_="now"
while [ $# -gt 0 ]; do
  case "$1" in
    --since) since="${2:?--since needs a value}"; shift 2 ;;
    --until) until_="${2:?--until needs a value}"; shift 2 ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
done

workspace_root="$(cd "$(dirname "$0")/../.." && pwd)"
if [ "$workspace_root" = "$HOME" ]; then
  default_roots="$HOME/Documents/TicketBoat"
else
  default_roots="$workspace_root"
fi
roots="${DAILY_REPORT_ROOTS:-$default_roots}"

to_unix() { # git date string -> unix seconds, evaluated inside a repo
  git -C "$1" rev-parse --since="$2" | sed 's/--max-age=//'
}

echo "window: since=\"$since\" until=\"$until_\" (local tz $(date +%z))"

IFS=':' read -r -a root_list <<< "$roots"
for root in "${root_list[@]}"; do
  for repo in "$root"/*/; do
    [ -d "$repo/.git" ] || continue
    repo="${repo%/}"
    name="$(basename "$repo")"
    email="$(git -C "$repo" config user.email)"
    author_name="$(git -C "$repo" config user.name)"
    since_ts="$(to_unix "$repo" "$since")"
    until_ts="$(to_unix "$repo" "$until_")"

    commits="$(git -C "$repo" log --all --source \
      --author="$email" --author="$author_name" \
      --since="$since" --until="$until_" \
      --date=format:'%Y-%m-%d %H:%M' \
      --format='  %cd  %h  [%S]  %s' 2>/dev/null \
      | sed 's#\[refs/heads/#[#; s#\[refs/remotes/#[#')"

    pushes="$(git -C "$repo" for-each-ref --format='%(refname)' refs/remotes \
      | while read -r ref; do
          git -C "$repo" reflog show --date=unix --format='%gd%x09%gs%x09%h' "$ref" 2>/dev/null
        done \
      | awk -F'\t' -v s="$since_ts" -v u="$until_ts" '
          $2 ~ /update by push/ {
            match($1, /@\{[0-9]+\}/); ts = substr($1, RSTART + 2, RLENGTH - 3) + 0
            ref = substr($1, 1, RSTART - 1)
            if (ts >= s && ts <= u) print ts "\t" ref "\t" $3
          }' \
      | sort -n \
      | while IFS=$'\t' read -r ts ref sha; do
          printf '  %s  pushed %s -> %s\n' "$(date -r "$ts" '+%Y-%m-%d %H:%M')" "$sha" "$ref"
        done)"

    branch="$(git -C "$repo" branch --show-current 2>/dev/null)"
    dirty="$(git -C "$repo" status --porcelain 2>/dev/null | wc -l | tr -d ' ')"
    ahead=""
    if git -C "$repo" rev-parse --abbrev-ref '@{u}' >/dev/null 2>&1; then
      ahead="$(git -C "$repo" rev-list --count '@{u}..HEAD' 2>/dev/null)"
    fi

    [ -z "$commits" ] && [ -z "$pushes" ] && [ "$dirty" = "0" ] && [ "${ahead:-0}" = "0" ] && continue

    echo
    echo "## $name"
    echo "current branch: ${branch:-detached}; uncommitted files: $dirty; unpushed commits: ${ahead:-no upstream}"
    if [ -n "$commits" ]; then echo "commits:"; echo "$commits"; fi
    if [ -n "$pushes" ]; then echo "pushes:"; echo "$pushes"; fi
  done
done
