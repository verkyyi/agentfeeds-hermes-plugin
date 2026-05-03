# Agent Feeds Hermes Plugin

Standalone Hermes plugin for Agent Feeds.

Agent Feeds gives Hermes a local-first ambient context layer. The plugin injects compact stream metadata into Hermes turns. The canonical Agent Feeds skill lives in the core repo and teaches Hermes how to discover, subscribe, refresh, and answer from Agent Feeds stream state through the bundled CLI.

The Agent Feeds skill runtime lives in the canonical core repo. Release bundles vendor that canonical skill unmodified; source installs clone or update it when the vendored copy is not present. The installer runs skill setup, installs background refresh, and exposes command wrappers on `PATH`.

## Install

```bash
git clone https://github.com/verkyyi/agentfeeds-hermes-plugin ~/.hermes/plugins-src/agentfeeds-hermes-plugin
~/.hermes/plugins-src/agentfeeds-hermes-plugin/install.sh
```

The installer:

- clones or updates Agent Feeds core at `~/.hermes/plugins-src/agentfeeds-core`
  - release bundles use the vendored canonical skill instead
- symlinks this repo to `~/.hermes/plugins/agentfeeds`
- symlinks the core repo to `~/.hermes/skills/agentfeeds`
- installs command wrappers in `~/.local/bin`
- enables the Hermes plugin when `hermes` is available on `PATH`
- runs the Agent Feeds skill setup
- initializes `~/.agentfeeds/catalog-cache/` and `~/.agentfeeds/catalog.md`
- installs or updates background polling when the host scheduler is supported

Override the core source when needed:

```bash
AGENTFEEDS_CORE_REPO=https://github.com/verkyyi/agentfeeds \
AGENTFEEDS_CORE_DIR=~/.hermes/plugins-src/agentfeeds-core \
AGENTFEEDS_CATALOG_DIR=~/.hermes/plugins-src/agentfeeds-catalog \
./install.sh
```

`AGENTFEEDS_CATALOG_DIR` is optional. Normal installs use the frozen catalog snapshot shipped in the canonical skill; set this only when testing a local catalog checkout.

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
plugin.yaml         # Hermes plugin manifest
__init__.py         # pre_llm_call metadata injection hook
recipes/           # progressively loaded skill recipes
bin/               # wrappers into the Agent Feeds core CLI
scripts/           # release bundle builder
install.sh         # local Hermes installer
vendor/            # generated release-only canonical skill copy
```

The Hermes skill itself is installed from the core Agent Feeds checkout so the plugin and portable skill bundle share one canonical `SKILL.md`.

Build a Hermes release bundle with:

```bash
python3 scripts/build_hermes_bundle.py --core-root ../agentfeeds --output dist/agentfeeds-hermes-plugin-v0.1.1.zip
```

## License

MIT
