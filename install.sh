#!/usr/bin/env bash
set -euo pipefail

SCRIPT="${BASH_SOURCE[0]}"
while [ -L "$SCRIPT" ]; do
  DIR="$(cd -P "$(dirname "$SCRIPT")" && pwd)"
  SCRIPT="$(readlink "$SCRIPT")"
  [[ "$SCRIPT" != /* ]] && SCRIPT="$DIR/$SCRIPT"
done
PLUGIN_DIR="$(cd "$(dirname "$SCRIPT")" && pwd)"
VENDORED_CORE_DIR="$PLUGIN_DIR/vendor/agentfeeds-skill"
CORE_REPO="${AGENTFEEDS_CORE_REPO:-https://github.com/verkyyi/agentfeeds}"
if [ -n "${AGENTFEEDS_CORE_DIR:-}" ]; then
  CORE_DIR="$AGENTFEEDS_CORE_DIR"
elif [ -f "$VENDORED_CORE_DIR/SKILL.md" ] && [ -f "$VENDORED_CORE_DIR/scripts/agentfeeds.py" ]; then
  CORE_DIR="$VENDORED_CORE_DIR"
else
  CORE_DIR="$HOME/.hermes/plugins-src/agentfeeds-core"
fi
CATALOG_DIR="${AGENTFEEDS_CATALOG_DIR:-}"

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 is required to install Agent Feeds. Install Python 3.11+ and rerun this script." >&2
  exit 127
fi

if [ "$CORE_DIR" != "$VENDORED_CORE_DIR" ] && ! command -v git >/dev/null 2>&1; then
  echo "git is required to install Agent Feeds core from $CORE_REPO." >&2
  exit 127
fi

mkdir -p "$HOME/.hermes/plugins" "$HOME/.hermes/skills" "$HOME/.local/bin" "$(dirname "$CORE_DIR")"

if [ "$CORE_DIR" = "$VENDORED_CORE_DIR" ]; then
  :
elif [ -d "$CORE_DIR/.git" ]; then
  git -C "$CORE_DIR" pull --ff-only
elif [ -e "$CORE_DIR" ]; then
  echo "Agent Feeds core path exists but is not a git checkout: $CORE_DIR" >&2
  echo "Set AGENTFEEDS_CORE_DIR to a checkout path or move the existing path aside." >&2
  exit 1
else
  git clone "$CORE_REPO" "$CORE_DIR"
fi

ln -sfn "$PLUGIN_DIR" "$HOME/.hermes/plugins/agentfeeds"
ln -sfn "$CORE_DIR" "$HOME/.hermes/skills/agentfeeds"
ln -sfn "$PLUGIN_DIR/bin/agentfeeds" "$HOME/.local/bin/agentfeeds"
ln -sfn "$PLUGIN_DIR/bin/agentfeeds-fetch" "$HOME/.local/bin/agentfeeds-fetch"
ln -sfn "$PLUGIN_DIR/bin/agentfeeds-install-poll" "$HOME/.local/bin/agentfeeds-install-poll"
ln -sfn "$PLUGIN_DIR/bin/agentfeeds-uninstall-poll" "$HOME/.local/bin/agentfeeds-uninstall-poll"

python3 "$CORE_DIR/scripts/setup.py"

if command -v hermes >/dev/null 2>&1; then
  hermes plugins enable agentfeeds
else
  echo "hermes not found on PATH; enable the plugin manually later: hermes plugins enable agentfeeds" >&2
fi

if [ -n "$CATALOG_DIR" ] && [ -f "$CATALOG_DIR/catalog/INDEX.json" ]; then
  export AGENTFEEDS_CATALOG_DIR="$CATALOG_DIR"
fi

python3 "$CORE_DIR/scripts/agentfeeds_fetch.py" --update-catalog --regenerate-catalog
if ! python3 "$CORE_DIR/scripts/agentfeeds.py" polling install; then
  echo "Background polling was not installed; run agentfeeds polling status --json for diagnostics." >&2
fi

echo "Installed Agent Feeds Hermes plugin, canonical core skill, and CLI wrappers."
echo "Agent Feeds core checkout: $CORE_DIR"
if [ -n "$CATALOG_DIR" ]; then
  echo "Agent Feeds catalog override: $CATALOG_DIR"
fi
echo "Hermes skill link: $HOME/.hermes/skills/agentfeeds -> $CORE_DIR"
echo "Agent Feeds background refresh: check with agentfeeds polling status --json"
echo "Restart Hermes for the plugin and skill to take effect."
