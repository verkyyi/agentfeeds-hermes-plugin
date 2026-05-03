from __future__ import annotations

import importlib.util
import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
PLUGIN = ROOT / "__init__.py"
INSTALLER = ROOT / "install.sh"


def load_plugin():
    spec = importlib.util.spec_from_file_location("agentfeeds_hermes_plugin", PLUGIN)
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(module)
    return module


def test_hermes_plugin_injects_compact_stream_metadata(tmp_path):
    plugin = load_plugin()
    plugin._agentfeeds_brief = lambda: None
    (tmp_path / "subscriptions.yaml").write_text(
        "\n".join(
            [
                "subscriptions:",
                "  - id: example/feed",
                "    title: Example feed",
                "    template: example/template",
                "",
            ]
        ),
        encoding="utf-8",
    )
    plugin.STATE_ROOT = tmp_path / "state"
    plugin.SUBSCRIPTIONS_FILE = tmp_path / "subscriptions.yaml"

    context = plugin._agentfeeds_context()["context"]

    assert "- example/feed: Example feed" in context
    assert "state/example.com/feed.json" not in context
    assert "stale" not in context


def test_hermes_plugin_falls_back_to_state_metadata(tmp_path):
    plugin = load_plugin()
    plugin._agentfeeds_brief = lambda: None
    state_dir = tmp_path / "state" / "example.com"
    state_dir.mkdir(parents=True)
    (state_dir / "feed.json").write_text(
        json.dumps({"_meta": {"subscription_id": "example/feed", "title": "Example feed"}, "data": {}}),
        encoding="utf-8",
    )
    plugin.STATE_ROOT = tmp_path / "state"
    plugin.SUBSCRIPTIONS_FILE = tmp_path / "missing.yaml"

    context = plugin._agentfeeds_context()["context"]

    assert "- example/feed: Example feed" in context


def test_hermes_plugin_prefers_cli_brief(tmp_path):
    plugin = load_plugin()
    plugin._agentfeeds_brief = lambda: "<agentfeeds>\nNo active local streams.\n</agentfeeds>"
    plugin.STATE_ROOT = tmp_path / "state"
    plugin.SUBSCRIPTIONS_FILE = tmp_path / "missing.yaml"

    context = plugin._agentfeeds_context()["context"]

    assert context == "<agentfeeds>\nNo active local streams.\n</agentfeeds>"


def test_installer_links_hermes_skill_to_core_checkout():
    installer = INSTALLER.read_text(encoding="utf-8")

    assert 'ln -sfn "$CORE_DIR" "$HOME/.hermes/skills/agentfeeds"' in installer
    assert 'ln -sfn "$PLUGIN_DIR" "$HOME/.hermes/plugins/agentfeeds"' in installer
    assert 'ln -sfn "$PLUGIN_DIR" "$HOME/.hermes/skills/agentfeeds"' not in installer
    assert "git clone \"$CATALOG_REPO\"" not in installer
    assert "AGENTFEEDS_CATALOG_DIR" in installer
