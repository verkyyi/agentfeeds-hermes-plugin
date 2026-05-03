# Agent Feeds Hermes Plugin

Standalone Hermes plugin and skill for Agent Feeds.

Agent Feeds gives Hermes a local-first ambient context layer. The plugin injects compact stream metadata into Hermes turns, and the skill teaches Hermes how to discover, subscribe, refresh, and answer from Agent Feeds stream state through the bundled CLI.

The Agent Feeds skill runtime and built-in template catalog live in separate repositories. This plugin installer clones or updates those checkouts, runs the skill setup, installs background refresh, and exposes command wrappers on `PATH`.

## Install

```bash
git clone https://github.com/verkyyi/agentfeeds-hermes-plugin ~/.hermes/plugins-src/agentfeeds-hermes-plugin
~/.hermes/plugins-src/agentfeeds-hermes-plugin/install.sh
```

The installer:

- clones or updates Agent Feeds core at `~/.hermes/plugins-src/agentfeeds-core`
- clones or updates the built-in template catalog at `~/.hermes/plugins-src/agentfeeds-catalog`
- symlinks this repo to `~/.hermes/plugins/agentfeeds`
- symlinks this repo to `~/.hermes/skills/agentfeeds`
- installs command wrappers in `~/.local/bin`
- enables the Hermes plugin when `hermes` is available on `PATH`
- runs the Agent Feeds skill setup
- initializes `~/.agentfeeds/catalog-cache/` and `~/.agentfeeds/catalog.md`
- installs or updates background polling when the host scheduler is supported

Override the core source when needed:

```bash
AGENTFEEDS_CORE_REPO=https://github.com/verkyyi/agentfeeds \
AGENTFEEDS_CORE_DIR=~/.hermes/plugins-src/agentfeeds-core \
AGENTFEEDS_CATALOG_REPO=https://github.com/verkyyi/agentfeeds-catalog \
AGENTFEEDS_CATALOG_DIR=~/.hermes/plugins-src/agentfeeds-catalog \
./install.sh
```

## Try It

Restart Hermes after installation, then ask:

```text
What Agent Feeds templates can I subscribe to?
```

```text
Subscribe me to Hacker News front page.
```

```text
Show me the current Hacker News front page from Agent Feeds.
```

## Layout

```text
SKILL.md            # Hermes skill instructions
plugin.yaml         # Hermes plugin manifest
__init__.py         # pre_llm_call metadata injection hook
recipes/           # progressively loaded skill recipes
bin/               # wrappers into the Agent Feeds core CLI
install.sh         # local Hermes installer
```

## License

MIT
