#!/usr/bin/env bash
set -euo pipefail

SCRIPT="${BASH_SOURCE[0]}"
while [ -L "$SCRIPT" ]; do
  DIR="$(cd -P "$(dirname "$SCRIPT")" && pwd)"
  SCRIPT="$(readlink "$SCRIPT")"
  [[ "$SCRIPT" != /* ]] && SCRIPT="$DIR/$SCRIPT"
done
PLUGIN_DIR="$(cd "$(dirname "$SCRIPT")" && pwd)"
CORE_REPO="${AGENTFEEDS_CORE_REPO:-https://github.com/verkyyi/agentfeeds}"
CORE_DIR="${AGENTFEEDS_CORE_DIR:-$HOME/.hermes/plugins-src/agentfeeds-core}"
CATALOG_REPO="${AGENTFEEDS_CATALOG_REPO:-https://github.com/verkyyi/agentfeeds-catalog}"
CATALOG_DIR="${AGENTFEEDS_CATALOG_DIR:-$HOME/.hermes/plugins-src/agentfeeds-catalog}"

if ! command -v uv >/dev/null 2>&1; then
  echo "uv is required to install Agent Feeds. Install uv and rerun this script." >&2
  exit 127
fi

if ! command -v git >/dev/null 2>&1; then
  echo "git is required to install Agent Feeds core from $CORE_REPO." >&2
  exit 127
fi

mkdir -p "$HOME/.hermes/plugins" "$HOME/.hermes/skills" "$HOME/.local/bin" "$(dirname "$CORE_DIR")" "$(dirname "$CATALOG_DIR")"

if [ -d "$CORE_DIR/.git" ]; then
  git -C "$CORE_DIR" pull --ff-only
elif [ -e "$CORE_DIR" ]; then
  echo "Agent Feeds core path exists but is not a git checkout: $CORE_DIR" >&2
  echo "Set AGENTFEEDS_CORE_DIR to a checkout path or move the existing path aside." >&2
  exit 1
else
  git clone "$CORE_REPO" "$CORE_DIR"
fi

if [ -d "$CATALOG_DIR/.git" ]; then
  git -C "$CATALOG_DIR" pull --ff-only
elif [ -e "$CATALOG_DIR" ]; then
  echo "Agent Feeds catalog path exists but is not a git checkout: $CATALOG_DIR" >&2
  echo "Set AGENTFEEDS_CATALOG_DIR to a checkout path or move the existing path aside." >&2
  exit 1
else
  git clone "$CATALOG_REPO" "$CATALOG_DIR"
fi

ln -sfn "$PLUGIN_DIR" "$HOME/.hermes/plugins/agentfeeds"
ln -sfn "$PLUGIN_DIR" "$HOME/.hermes/skills/agentfeeds"
ln -sfn "$PLUGIN_DIR/bin/agentfeeds" "$HOME/.local/bin/agentfeeds"
ln -sfn "$PLUGIN_DIR/bin/agentfeeds-fetch" "$HOME/.local/bin/agentfeeds-fetch"
ln -sfn "$PLUGIN_DIR/bin/agentfeeds-install-poll" "$HOME/.local/bin/agentfeeds-install-poll"
ln -sfn "$PLUGIN_DIR/bin/agentfeeds-uninstall-poll" "$HOME/.local/bin/agentfeeds-uninstall-poll"

if command -v hermes >/dev/null 2>&1; then
  hermes plugins enable agentfeeds
else
  echo "hermes not found on PATH; enable the plugin manually later: hermes plugins enable agentfeeds" >&2
fi

AGENTFEEDS_CATALOG_DIR="$CATALOG_DIR" uv run --project "$CORE_DIR" agentfeeds-fetch --update-catalog --regenerate-catalog

echo "Installed Agent Feeds Hermes plugin, skill, and CLI wrappers."
echo "Agent Feeds core checkout: $CORE_DIR"
echo "Agent Feeds catalog checkout: $CATALOG_DIR"
echo "Restart Hermes for the plugin and skill to take effect."
