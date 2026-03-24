# @agiterra/personai

Persistent agent identity for Claude Code agents. Memory vault, journal,
association search, boot sequence, and session state tracking.

Gives agents identity that survives context compaction. Pure identity plugin —
no messaging, no external connectivity. Agents compose Personai with
communication plugins (like Exchange) as needed.

## Install

As a Claude Code plugin:

```json
{
  "enabledPlugins": {
    "personai@agiterra": true
  }
}
```

## What's included

### Skills

- `/personai:boot` — Restore identity after compaction
- `/personai:init` — Set up a new agent
- `/personai:scan` — Scan memory file headers
- `/personai:index` — Build/maintain semantic keyword index
- `/personai:search` — Search memory by keywords
- `/personai:associate` — Fast keyword-only associations (<100ms)
- `/personai:enrich` — Deep hybrid search (keyword + vector + Sonnet)
- `/personai:journal` — Append-only log of WHY beliefs exist
- `/personai:calibrate` — Measure compaction fidelity
- `/personai:vectorize` — Build vector embeddings

### Hooks

- **UserPromptSubmit** — Injects relevant memory context on each prompt
- **PreCompact** — Backs up transcript and recovery data
- **SessionStart** — Reminds agent to boot after compaction

### Enrichment

Personai provides `scripts/association-search.py` which can be used as an
enrichment source by messaging plugins. See the Exchange plugin docs for
an example of wiring Personai associations into inbound message context.

```bash
# CLI usage
python3 scripts/association-search.py "search query"
python3 scripts/association-search.py --json "structured output"
```

Output format:

```json
{
  "results": [
    {
      "source": "memory/some-file.md",
      "type": "vault",
      "score": 0.85,
      "summary": "...",
      "matched_keywords": ["..."]
    }
  ]
}
```
