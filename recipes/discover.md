# Discover Recipe

Use this when the user asks what Agent Feeds templates or active streams are available.

For templates the user can subscribe to:

```bash
agentfeeds templates find <query>
agentfeeds templates show <template-id> --json
```

For active subscriptions already available as local context:

```bash
agentfeeds streams list --json
agentfeeds streams find <query> --json
```

Present the best matches with title, template id or subscription id, required parameters, auth requirement, and quality tier when available.

Suggest one best template to subscribe to when there is a clear match. If no template fits, offer local template authoring with `recipes/template-authoring.md`.
