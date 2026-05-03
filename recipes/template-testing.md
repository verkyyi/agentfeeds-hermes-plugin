# Template Testing Recipe

Use this after creating or editing an Agent Feeds template.

1. Validate local template definitions:

```bash
agentfeeds admin templates validate
```

2. If the template uses `local_command`, approve the exact substituted command before testing:

```bash
agentfeeds admin templates approve-command <template-id> [key=value ...]
```

3. Run the template once without writing state or touching subscriptions:

```bash
agentfeeds admin templates test <template-id> [key=value ...]
agentfeeds admin templates test <template-id> [key=value ...] --json
```

4. Confirm discovery sees the template:

```bash
agentfeeds templates find <query>
```

5. If you need to test subscription materialization, use a temporary Agent Feeds root instead of the user's live subscriptions. Copy the drafted local template tree into the temp root first:

```bash
tmp="$(mktemp -d)"
mkdir -p "$tmp/templates"
cp -R ~/.agentfeeds/templates/streams "$tmp/templates/"
cp -R ~/.agentfeeds/templates/schemas "$tmp/templates/"
agentfeeds --root "$tmp" subscribe <template-id> [key=value ...] --no-fetch
agentfeeds --root "$tmp" refresh --stream <subscription-id>
agentfeeds --root "$tmp" streams health --json
agentfeeds --root "$tmp" streams read <subscription-id> --limit 20 --json
```

6. Verify:
   - `_meta.subscription_id` is the concrete instance id.
   - `_meta.template_id` is the template id.
   - `data` matches the schema and contains only intended fields.
   - private/local sources are read-only.

Only subscribe in the user's live `~/.agentfeeds` root after the smoke test passes or the user explicitly asks to install the subscription.
