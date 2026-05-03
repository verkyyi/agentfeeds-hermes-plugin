# Refresh Recipe

Use this when the user asks to refresh Agent Feeds data.

For one stream:

```bash
agentfeeds refresh --stream <subscription-id>
```

For every stream:

```bash
agentfeeds refresh --all
```

After refresh, read the relevant stream through `agentfeeds streams read <subscription-id> --limit 20 --json` before answering.
Prefer one-stream refreshes for stale matching context. Use `--all` only when the user asks for a full refresh or every active stream is intentionally being warmed.
