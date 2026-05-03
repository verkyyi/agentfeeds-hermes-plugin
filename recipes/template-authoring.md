# Template Authoring Recipe

Use this when the user wants Agent Feeds to support a source that no current template covers.

1. Run `agentfeeds templates find <query>` and confirm no existing template fits.
2. Run `agentfeeds admin templates adapters` and classify the source:
   - `local_file` for one local text, Markdown, or JSON file.
   - `local_command` for an explicitly approved local read command.
   - `json_http` for one HTTP JSON snapshot.
   - `paginated_json_http` for HTTP JSON event lists.
   - `rss` for RSS or Atom feeds.
   - `ical` for calendar feeds.
3. Pick a template id in `category/name` form. Prefer personal/local categories for private sources, such as `local/...` or `personal/...`.
4. Pick the mode:
   - `snapshot` for one current state.
   - `event` for a list of recent items.
5. Define required parameters. Do not bake user-specific secrets into template YAML.
6. Run `agentfeeds admin templates scaffold <adapter-kind> <template-id>`.
7. Edit the generated YAML under `~/.agentfeeds/templates/streams/<category>/<name>.yaml`.
8. Edit the generated schema under `~/.agentfeeds/templates/schemas/event-types/<type>.v1.json` when the scaffold created one.
9. Reuse built-in schemas for `rss`, `ical`, and `local_command` unless the user needs custom fields.
10. Keep template descriptions short and operator-facing. Include tags that help `agentfeeds templates find`.
11. Run `recipes/template-testing.md`.

For local/private sources, prefer read-only snapshots. Template adapters should read from the source and write Agent Feeds state; they should not mutate the original source.

For `local_command`, use argv arrays only. Do not use shell strings. Only create command templates for commands the operator explicitly requested or approved. Before testing or subscribing, show the exact command and run:

```bash
agentfeeds admin templates approve-command <template-id> [key=value ...]
```

If the command or parameters change, approve the new digest before running it.

Snapshot command with optional JSON parsing:

```yaml
mode: snapshot
adapter:
  kind: local_command
  command: ["example-cli", "status", "--json"]
  timeout_seconds: 20
  max_output_bytes: 1048576
  parse: json
  transform:
    language: jmespath
    expression: "{title: name, content: status, updated_at: updated_at}"
```

Event command from JSON items:

```yaml
mode: event
adapter:
  kind: local_command
  command: ["example-cli", "recent", "--json"]
  timeout_seconds: 20
  max_output_bytes: 1048576
  parse: json
  items_from: items
  id_from: id
  time_from: updated_at
  transform:
    language: jmespath
    expression: "{title: title, content: summary, updated_at: updated_at}"
```

Minimal stream template, equivalent to `agentfeeds admin templates scaffold local_file local/example`:

```yaml
id: local/example
title: Example local source
description: Read-only snapshot of example local data.
type: local.example
mode: snapshot
schema_url: https://agentfeeds.dev/schemas/local.example.v1.json
schema_version: 1.0.0
parameters:
  - name: path
    type: string
    description: Absolute or home-relative file path
    required: true
source_uri_template: "feed://local.example/source?path={path}"
adapter:
  kind: local_file
  path: "{path}"
recommended_poll_interval_seconds: 300
auth: none
tags: [local, private, no-auth]
quality_tier: verified
contributed_by: agentfeeds
```
