#!/usr/bin/env bash
# Verify the installer exposes every nested repo skill through a flat harness link.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TEMP_ROOT="$(mktemp -d)"
trap 'rm -rf "$TEMP_ROOT"' EXIT

HOME="$TEMP_ROOT/home" bash "$ROOT/install.sh" >/dev/null
for manifest in "$ROOT"/claude/skills/*/*/SKILL.md; do
  group="$(basename "$(dirname "$(dirname "$manifest")")")"
  child="$(basename "$(dirname "$manifest")")"
  link="$HOME/.claude/skills/$group-$child"
  [ -L "$link" ] || { echo "missing nested skill link: $group-$child" >&2; exit 1; }
  [ "$(readlink "$link")" = "$(dirname "$manifest")" ] || {
    echo "wrong nested skill target: $group-$child" >&2; exit 1;
  }
done

echo "nested skill installation verified"
