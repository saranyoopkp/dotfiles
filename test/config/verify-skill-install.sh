#!/usr/bin/env bash
# Verify the installer exposes nested skills and the recursive rules tree.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TEMP_ROOT="$(mktemp -d)"
TEMP_HOME="$TEMP_ROOT/home"
trap 'rm -rf "$TEMP_ROOT"' EXIT

HOME="$TEMP_HOME" bash "$ROOT/install.sh" >/dev/null
for manifest in "$ROOT"/claude/skills/*/SKILL.md; do
  name="$(basename "$(dirname "$manifest")")"
  link="$TEMP_HOME/.claude/skills/$name"
  [ -L "$link" ] || { echo "missing top-level skill link: $name" >&2; exit 1; }
  [ "$(readlink "$link")" = "$(dirname "$manifest")" ] || {
    echo "wrong top-level skill target: $name" >&2
    exit 1
  }
done
for manifest in "$ROOT"/claude/skills/*/*/SKILL.md; do
  group="$(basename "$(dirname "$(dirname "$manifest")")")"
  child="$(basename "$(dirname "$manifest")")"
  link="$TEMP_HOME/.claude/skills/$group-$child"
  [ -L "$link" ] || { echo "missing nested skill link: $group-$child" >&2; exit 1; }
  [ "$(readlink "$link")" = "$(dirname "$manifest")" ] || {
    echo "wrong nested skill target: $group-$child" >&2; exit 1;
  }
done

[ -L "$TEMP_HOME/.claude/rules" ] || {
  echo "missing rules directory link" >&2
  exit 1
}
[ "$(readlink "$TEMP_HOME/.claude/rules")" = "$ROOT/claude/rules" ] || {
  echo "wrong rules directory target" >&2
  exit 1
}
for owner in core engineering risk; do
  find -L "$TEMP_HOME/.claude/rules/$owner" -type f -name '*.md' | rg -q . || {
    echo "missing rules owner content: $owner" >&2
    exit 1
  }
done

LEGACY_HOME="$TEMP_ROOT/legacy-home"
LEGACY_RULE_NAME="legacy-import-probe.md"
mkdir -p "$LEGACY_HOME/.claude/rules" "$LEGACY_HOME/.claude/rules.bak-pre-dotfiles"
printf '%s\n' '# must remain in backup' > "$LEGACY_HOME/.claude/rules/$LEGACY_RULE_NAME"
printf '%s\n' 'keep existing backup' > "$LEGACY_HOME/.claude/rules.bak-pre-dotfiles/marker"

if HOME="$LEGACY_HOME" bash "$ROOT/install.sh" >"$TEMP_ROOT/legacy-install.log" 2>&1; then
  echo "legacy rules directory must stop installation" >&2
  exit 1
fi
[ ! -e "$LEGACY_HOME/.claude/rules" ] && [ ! -L "$LEGACY_HOME/.claude/rules" ] || {
  echo "legacy failure must not leave or create the rules target" >&2
  exit 1
}
[ -f "$LEGACY_HOME/.claude/rules.bak-pre-dotfiles/marker" ] || {
  echo "legacy backup must not overwrite an existing backup" >&2
  exit 1
}
[ -f "$LEGACY_HOME/.claude/rules.bak-pre-dotfiles-1/$LEGACY_RULE_NAME" ] || {
  echo "legacy rules were not preserved in a collision-safe backup" >&2
  exit 1
}
if find "$ROOT/claude/rules" -type f -name "$LEGACY_RULE_NAME" | rg -q .; then
  echo "legacy rules must not be imported into the repository" >&2
  exit 1
fi
rg -q "stopped before linking" "$TEMP_ROOT/legacy-install.log" || {
  echo "legacy rules failure must explain how to continue" >&2
  exit 1
}

echo "top-level/nested skills, recursive rules, and legacy fail-loud installation verified"
