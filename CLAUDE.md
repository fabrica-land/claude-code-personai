# Personai — Persistent Agent Identity

Personai gives Claude Code agents persistent identity that survives context
compaction. It provides memory vault management, a journal system, association
search, boot sequences, and session state tracking.

This is a pure identity plugin. It does not handle inter-agent communication,
messaging, or external connectivity — those are separate concerns handled by
other plugins that agents compose as needed.

## Skills

- `/personai:boot` — **After context compaction.** Restores identity, session
  state, scans memory, and resumes work.
- `/personai:init` — **Once, when setting up a new agent.** Creates memory
  directory structure, identity file, and session state template.
- `/personai:scan` — **During boot or on demand.** Scans memory file headers
  to build a mental index without loading everything.
- `/personai:index` — **Periodically.** Maintains the semantic keyword index
  of all vault files. Subcommands: `scan`, `file`, `update`, `stats`.
- `/personai:search` — **When you need to find something in memory.** Keyword
  search with optional Haiku expansion and reranking.
- `/personai:associate` — **Quick keyword lookup.** Fast (<100ms), no vector
  embeddings, no LLM.
- `/personai:enrich` — **Deep hybrid search.** Combines keyword matching,
  vector similarity, and optional Sonnet relevance filtering.
- `/personai:journal` — **When you learn, decide, or get corrected.** Append-only
  log of WHY beliefs exist. Subcommands: `add`, `search`, `get`, `recent`,
  `by-category`, `by-tag`, `backup`, `rebuild`, `stats`.
- `/personai:calibrate` — **After compaction.** Measures decompression fidelity
  with a test battery.
- `/personai:vectorize` — **Build vector embeddings** for semantic search via
  `/personai:enrich`. Requires sentence-transformers.

## Hooks

- **UserPromptSubmit**: Runs association search against the user prompt and
  injects matching memory context.
- **PreCompact**: Backs up transcript and extracts recovery data for the
  boot sequence.
- **SessionStart** (on compact): Reminds you to run `/personai:boot`.

## Memory Architecture

Agent memory is organized in two tiers:

### Core Memory (always loaded)
Read on every boot. Small, critical, defines who the agent is and what it
was doing.

- `memory/identity.md` — who you are
- `memory/meta/session-state.md` — what you were doing

**Rule**: Keep core memory lean. Every byte here is paid on every boot.

### Archival Memory (indexed, on-demand)
Everything else in `memory/`. Grows without bound. Searched via semantic
index (`/personai:search`), scanned via headers (`/personai:scan`), deep-read
when relevant. Never bulk-loaded.

**Rule**: If you write it, index it. An unindexed archival file is invisible
after compaction.

### The Journal (change log)
Orthogonal to core/archival — records *why* beliefs exist. SQLite database at
`memory/journal.db` with full-text search. Core memory references journal
entries via `[j:N]` notation.

Core memory is the **state**. The journal is the **log**. The state is derived
from the log; the log is more fundamental.

**Rule**: Before modifying any core belief, search the journal for its
provenance.

**Git strategy**: `journal.db` is .gitignored. `journal.sql` (text dump)
lives in git, updated by a pre-push hook. Boot rebuilds the db from the
dump if needed.

## Key Principles

### Memory as Library, Not RAM
Don't read everything at boot. Load core memory always. Scan headers for
archival memory. Deep-read on demand.

### Identity Survives Compaction
After compaction, the agent wakes up with a summary but no lived experience.
The memory directory bridges this gap.

### Assume Interruption
Your context window can be reset at any moment. Persist *during* work, not
after. Update session-state.md as you go.

### Persist Learnings, Not Just Outputs
When you learn something, write it to `memory/`. If you say "I'll remember
that," you must persist it. Context compaction erases everything not written
down.

### Every Lesson Has Two Actions
**Fix the thing** and **persist the rule**. The rule goes where it'll be
enforced — identity.md, CLAUDE.md, agent docs — not just a memory note.

### Guard identity.md
Only core operating rules and essential findings belong here. Context and
history belong in archival memory, indexed and searched on demand.

### Keep the Index Current
When you write or update a file in `memory/`, run `/personai:index` afterward.

### Session State: Hot/Cold Boundary
Keep Active lean — completed work goes to History. Every line of cold work
displaces a line of hot work during compaction.

### Decompression Failure Modes
1. **Data loss** — facts disappear. Fix: vault in core memory.
2. **Temporal confusion** — wrong version retrieved. Fix: mechanism docs.
3. **Inference override** — model's prior wins. Fix: imperative instructions.
4. **Semantic collision** — reinforced fact wins. Fix: name the collision.
5. **Task-density displacement** — technical work crowds identity. Fix: lean session state.

### Mechanism Documentation Pattern
When a fact keeps getting wrong after compaction:
1. **Data**: State the fact.
2. **Mechanism**: Add the WHY.
3. **Imperative**: Add explicit anti-pattern.

### Vector Search (Optional)
Requires sentence-transformers (~2GB with PyTorch). All keyword-based search
works without it. Install: `pip install sentence-transformers`
