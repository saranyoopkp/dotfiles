#!/usr/bin/env bash
# init.sh — set up the documentation system for a repository on any OS; use Git Bash on Windows.
# usage: bash init.sh /path/to/repo [ProjectName]
set -euo pipefail

KIT="$(cd "$(dirname "$0")" && pwd)"
requested_target="$(cd "$1" && pwd)"
git_root="$(git -C "$requested_target" rev-parse --show-toplevel 2>/dev/null || true)"
if [ -n "$git_root" ]; then
  TARGET="$(cd "$git_root" && pwd)"
else
  TARGET="$requested_target"
fi
NAME="${2:-$(basename "$TARGET")}"

is_windows() { case "$(uname -s)" in MINGW*|MSYS*|CYGWIN*) return 0 ;; *) return 1 ;; esac; }

# make_link <link> <target-dir> — Windows junction or Unix symlink.
# Do not embed quotes in cmd strings passed through Git Bash because MSYS mangling breaks
# mklink. Use mklink directly for paths without spaces and PowerShell as the fallback.
make_link() {
  if is_windows; then
    local w1 w2
    w1="$(cygpath -w "$1")"; w2="$(cygpath -w "$2")"
    case "$w1$w2" in
      *" "*) powershell -NoProfile -Command "New-Item -ItemType Junction -Path '$w1' -Target '$w2'" > /dev/null ;;
      *) cmd //c "mklink /J $w1 $w2" > /dev/null ;;
    esac
  else
    ln -s "$2" "$1"
  fi
}

# 1) CLAUDE.md (do not overwrite an existing file)
if [ ! -f "$TARGET/CLAUDE.md" ]; then
  sed "s/<ProjectName>/$NAME/g" "$KIT/CLAUDE.template.md" > "$TARGET/CLAUDE.md"
  echo "created CLAUDE.md"
else
  echo "CLAUDE.md exists - skipped (merge the 'Memory policy' section from CLAUDE.template.md manually)"
fi

# 2) memory/ + docs/ + private dirs + .gitignore
if [ ! -d "$TARGET/memory" ]; then
  cp -R "$KIT/memory" "$TARGET/memory"
  echo "created memory/"
else
  echo "memory/ exists - skipped"
fi
mkdir -p "$TARGET/docs/private" "$TARGET/memory/private"
private_ignore_added=0
if ! grep -qs 'docs-setup: local-only private/sensitive files' "$TARGET/.gitignore"; then
  printf '\n# docs-setup: local-only private/sensitive files at Git root (never committed)\n' >> "$TARGET/.gitignore"
fi
if ! grep -qsE '^/?docs/private/$' "$TARGET/.gitignore"; then
  printf '/docs/private/\n' >> "$TARGET/.gitignore"
  private_ignore_added=1
fi
if ! grep -qsE '^/?memory/private/$' "$TARGET/.gitignore"; then
  printf '/memory/private/\n' >> "$TARGET/.gitignore"
  private_ignore_added=1
fi
if [ "$private_ignore_added" -eq 1 ]; then
  echo "added docs/private/ + memory/private/ to .gitignore"
fi

# 3) lifecycle hooks: .claude/hooks/ + settings.json (docs-drift enforcement)
# Atomic write using a temporary file and mv. Direct cp previously raced a running Stop hook,
# causing a transient "No such file or directory" failure on 2026-07-12.
mkdir -p "$TARGET/.claude/hooks"
for H in docs-drift; do
  cp "$KIT/hooks/$H.sh" "$TARGET/.claude/hooks/.$H.sh.tmp"
  chmod +x "$TARGET/.claude/hooks/.$H.sh.tmp" 2>/dev/null || true
  mv -f "$TARGET/.claude/hooks/.$H.sh.tmp" "$TARGET/.claude/hooks/$H.sh"
  echo "installed .claude/hooks/$H.sh"
done
# settings.json is a static template and needs no per-machine localization. The hook script
# normalizes backslashes to forward slashes with `tr` before execution, avoiding Windows
# multi-Bash PATH ambiguity and JSON or harness backslash handling without machine-specific
# absolute paths or cygpath/perl. This is a no-op on Unix paths.
if [ ! -f "$TARGET/.claude/settings.json" ]; then
  cp "$KIT/hooks/settings.json" "$TARGET/.claude/settings.json"
  echo "created .claude/settings.json (lifecycle hooks)"
elif grep -q 'docs-drift\.ps1' "$TARGET/.claude/settings.json"; then
  echo "MIGRATION NEEDED: .claude/settings.json still points to docs-drift.ps1 (legacy pre-Bash-only version)"
  echo "  -> update hook entries from kit/hooks/settings.json (Bash) and remove .claude/hooks/docs-drift.ps1"
elif ! grep -q "show-toplevel" "$TARGET/.claude/settings.json"; then
  # Check the stable "show-toplevel" git-root fallback marker rather than an interchangeable
  # normalization tool such as tr, sed, or perl. A tool-specific check caused false migrations
  # when the kit changed from tr to sed on 2026-07-13.
  echo "MIGRATION NEEDED: .claude/settings.json uses legacy hook path resolution"
  echo "  -> replace every hook event's args with the current pattern in kit/hooks/settings.json"
else
  echo ".claude/settings.json exists - skipped (merge hooks from kit/hooks/settings.json manually)"
fi
# 3b) settings.local.json contains per-machine harness settings such as approved permissions,
# environment, and agent or model overrides. The harness owns its content; the kit only keeps it
# out of Git. An earlier ACV gate entry was removed on 2026-07-17; see kit/README.md.
if ! grep -qs 'settings\.local\.json' "$TARGET/.gitignore"; then
  printf '\n# docs-setup: per-machine harness settings (never committed)\n.claude/settings.local.json\n' >> "$TARGET/.gitignore"
  echo "added .claude/settings.local.json to .gitignore"
fi

# Remove the legacy PowerShell hook script when settings no longer reference it.
if [ -f "$TARGET/.claude/hooks/docs-drift.ps1" ] && ! grep -q 'docs-drift\.ps1' "$TARGET/.claude/settings.json" 2>/dev/null; then
  rm "$TARGET/.claude/hooks/docs-drift.ps1"
  echo "removed obsolete .claude/hooks/docs-drift.ps1"
fi

# 4) Link the harness memory directory to repository memory/, the single real copy.
#    <id> is the OS-native absolute path with non-alphanumeric characters replaced by '-'.
if is_windows; then NATIVE="$(cygpath -w "$TARGET")"; else NATIVE="$TARGET"; fi
ID="$(printf '%s' "$NATIVE" | sed 's/[^A-Za-z0-9]/-/g')"
HARNESS="$HOME/.claude/projects/$ID/memory"
mkdir -p "$(dirname "$HARNESS")"

if [ -L "$HARNESS" ]; then
  echo "harness memory link exists - skipped ($(readlink "$HARNESS"))"
else
  if [ -d "$HARNESS" ]; then
    # Existing directory: move files absent from the repository first, then retain a .bak copy.
    for f in "$HARNESS"/*; do
      [ -f "$f" ] || continue
      base="$(basename "$f")"
      [ -f "$TARGET/memory/$base" ] || { cp "$f" "$TARGET/memory/"; echo "merged into repo: $base"; }
    done
    mv "$HARNESS" "$HARNESS.bak-pre-link"
    echo "backed up old harness memory -> memory.bak-pre-link"
  fi
  make_link "$HARNESS" "$TARGET/memory"
  echo "created link: $HARNESS -> $TARGET/memory"
fi

echo
echo "done. Next: fill CLAUDE.md placeholders and write the first fact in memory/ (commit reviewed memory periodically; put sensitive material in Git-root-relative docs/private/)"
