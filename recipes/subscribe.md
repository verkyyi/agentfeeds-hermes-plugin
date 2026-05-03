# Subscribe Recipe

Use this when the user asks to subscribe to an ambient data stream.

1. Determine the topic or source the user wants covered.
2. Search built-in and local templates:

```bash
agentfeeds templates search <query>
```

3. Inspect likely matches:

```bash
agentfeeds templates show <template-id> --json
```

4. Prefer templates in this order:
   - `quality_tier: verified`
   - `auth: none`
   - closest parameter fit to the user's request
5. Fill all required parameters from the user's request.
6. Run:

```bash
agentfeeds subscribe <template-id> [key=value ...]
```

7. If the user supplied a preferred name, pass `--id <subscription-id>` and/or `--title "<title>"`.
8. Confirm health and read the new stream when useful:

```bash
agentfeeds streams health --json
agentfeeds streams read <subscription-id> --limit 20 --json
```

For local files, use `agentfeeds subscribe local/file path=<path>`. Local file subscriptions are read-only snapshots; do not edit the source file or hand-write files in `~/.agentfeeds/state/`.

Do not write directly to `~/.agentfeeds/state/`.
