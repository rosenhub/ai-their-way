#!/bin/sh
# AI Their Way — install any subset of the eight skills.
# Each skill has its own installer; this script just runs them.
#
#   curl -fsSL https://raw.githubusercontent.com/rosenhub/ai-their-way/main/install-all.sh | sh
#   sh install-all.sh                       # interactive pick
#   sh install-all.sh --all                 # everything
#   sh install-all.sh no-subtext one-thing  # named skills
#   add --project to also install into the current repo
#   add --dry-run to see what would happen

set -eu

ORG="rosenhub"
SKILLS="no-subtext what-did-they-mean never-say-remember easy-read presume-competence low-demand is-this-a-scam one-thing"
ALL=0
PASS=""
PICK=""

for a in "$@"; do
  case "$a" in
    --all) ALL=1 ;;
    --project|--dry-run) PASS="$PASS $a" ;;
    -h|--help) sed -n '2,10p' "$0"; exit 0 ;;
    *) PICK="$PICK $a" ;;
  esac
done

valid() { for s in $SKILLS; do [ "$s" = "$1" ] && return 0; done; return 1; }

if [ "$ALL" = 1 ]; then
  PICK="$SKILLS"
elif [ -z "$PICK" ]; then
  if [ -t 0 ]; then
    echo "AI Their Way — pick skills (numbers, space-separated), or 'all':"
    i=0; for s in $SKILLS; do i=$((i+1)); echo "  $i) $s"; done
    printf "> "; read -r ans
    if [ "$ans" = "all" ]; then PICK="$SKILLS"; else
      for n in $ans; do
        i=0; for s in $SKILLS; do i=$((i+1)); [ "$i" = "$n" ] && PICK="$PICK $s"; done
      done
    fi
  else
    echo "No skills named and no terminal to ask. Use --all or name skills:" >&2
    echo "  curl ... | sh -s -- --all" >&2
    exit 1
  fi
fi

[ -z "$PICK" ] && { echo "Nothing picked."; exit 0; }

fetch() {
  if command -v curl >/dev/null 2>&1; then curl -fsSL "$1"
  elif command -v wget >/dev/null 2>&1; then wget -qO- "$1"
  else echo "Need curl or wget." >&2; exit 1; fi
}

for s in $PICK; do
  if ! valid "$s"; then echo "Unknown skill: $s (one of: $SKILLS)" >&2; continue; fi
  echo "=== $s"
  fetch "https://raw.githubusercontent.com/$ORG/$s/main/install.sh" | sh -s -- $PASS
done

echo "AI Their Way: done. Open a new session for the skills to take effect."
