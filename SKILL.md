---
name: agentfeeds
description: Use local Agent Feeds subscriptions and stream state for ambient context. Use at Hermes session start to check background refresh and compact stream brief, and before web search or source-specific work when subscribed changing context such as RSS/news, GitHub, calendars, weather, local files, private sources, templates, subscriptions, or stream state may cover the prompt.
version: 0.1.0
author: verkyyi
license: MIT
platforms: [macos, linux]
metadata:
  hermes:
    tags: [Context, Feeds, Local-first, Ambient Context, Personal Agents]
---

# Agent Feeds

Use Agent Feeds to answer from local subscribed streams before searching the web or rerunning source-specific data pipelines.

Hermes should treat Agent Feeds commands as an internal control plane. The operator asks for outcomes in natural language; run the needed commands and report concise results. Do not make CLI flags the primary user experience.

Vocabulary:

- Template: reusable feed definition. Some templates need no parameters; others require parameters.
- Subscription: configured active instance of a template.
- Stream: refreshed readable data for an active subscription.

## Session Start

At the start of a session:

```bash
agentfeeds polling status --json
agentfeeds streams health --json
agentfeeds brief
```

The plugin also tries to inject `agentfeeds brief` automatically. The default brief is stable and data-only; place it in a system-level or persistent prompt slot when the host supports that.

If polling is missing, run:

```bash
agentfeeds polling install
```

Background refresh is required for normal ambient use. If the scheduler is unsupported or broken, continue with explicit refreshes but tell the operator ambient awareness is degraded when it affects the answer.

## Answering Questions

When a prompt may be covered by subscribed changing context:

1. Search local state first:

```bash
agentfeeds search <topic> --json
```

2. If a non-stale match covers the question, read the matching stream and answer from local state:

```bash
agentfeeds streams read <subscription-id> --limit 20 --json
```

3. If a matching stream is stale and freshness matters, refresh only that stream:

```bash
agentfeeds-fetch --stream <subscription-id>
```

4. Use web search or other external tools only when local streams do not cover the prompt, cannot refresh, or the user explicitly asks for outside/current web information beyond subscribed data.

Do not hand-read or edit files under `~/.agentfeeds/state/` during normal operation. Use the CLI surfaces.

## Subscribing

When the user asks to subscribe to a source, load `recipes/subscribe.md` and follow it.

Current command patterns:

```bash
agentfeeds templates search <query>
agentfeeds templates show <template-id> --json
agentfeeds subscribe <template-id> [key=value ...]
agentfeeds subscribe <template-id> [key=value ...] --id <subscription-id> --title "<title>"
agentfeeds unsubscribe <subscription-id>
agentfeeds streams list --json
agentfeeds streams health --json
agentfeeds streams read <subscription-id> --limit 20 --json
```

If no template fits the requested source, offer local template authoring and load `recipes/template-authoring.md`.

## Template Authoring

When the user asks whether Agent Feeds can support a new source, first search templates:

```bash
agentfeeds templates search <query>
```

If there is no suitable built-in template, help draft one:

```bash
agentfeeds templates adapters
agentfeeds templates path
agentfeeds templates scaffold <adapter-kind> <template-id>
agentfeeds templates validate
agentfeeds templates test <template-id> [key=value ...]
```

Use `recipes/template-authoring.md` to create template YAML and schemas. Use `recipes/template-testing.md` to validate and smoke-test a template. Prefer private/local templates for operator-specific awareness before suggesting public catalog contributions.

For `local_command`, use argv arrays only. Show the exact command to the operator and run `agentfeeds templates approve-command <template-id> [key=value ...]` only after approval. Avoid commands that mutate files, cloud resources, accounts, or external services.

## Unsubscribing

When the user asks to remove a subscription, load `recipes/unsubscribe.md` and follow it.

## Safety Rules

- Change subscriptions with `agentfeeds subscribe` and `agentfeeds unsubscribe`.
- Refresh through `agentfeeds-fetch` or `agentfeeds refresh`.
- Do not hand-write state or status files.
- Do not include secrets in template YAML.
- Treat Agent Feeds as warm changing context, not durable memory, semantic search, or a data warehouse.
