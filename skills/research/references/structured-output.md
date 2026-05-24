# Structured Output for Large-Scale Research

This reference enables file-based structured output for research involving many items (10+), such as competitive analysis, benchmark surveys, or technology comparisons. Results are stored as intermediate documents in **Jot** for visibility, collaboration, and resume support.

## When to Use Structured Output

Use structured output (instead of direct chat synthesis) when:

- **Many items** — Researching 10+ entities (tools, companies, papers, etc.)
- **Comparison needed** — Side-by-side evaluation across uniform criteria
- **Stakeholder review** — Results need to be reviewed before finalization
- **Resume support** — Research spans multiple sessions; progress must be preserved
- **Persistent artifacts** — User wants to keep research files for future reference

> **Note:** The user never edits YAML/JSON files directly. The agent generates and manages all files. The user interacts through **chat** (approving items, answering questions) and **Jot documents** (reviewing results, adding comments). Files are implementation details the agent handles.

## Architecture

```
Research Planning (Jot document)
    ↓
Session Registration (Registry entry for RNNN)
    ↓
Outline Generation (outline.yaml in Jot)
    ↓
Field Definition (fields.yaml in Jot)
    ↓
Deep Research (per-item JSON in Jot)
    ↓
Report Generation (report.md in Jot)
```

All intermediate files are stored as **Jot documents** so they are:
- **Visible** — User can review progress anytime
- **Collaborative** — Teammates can comment on specific items or fields
- **Resumable** — Progress persists across sessions
- **Versioned** — Document history shows evolution
- **Isolated** — Multiple research projects don't interfere (see Session Namespacing below)

## Session Namespacing

When running multiple research projects, use **session IDs** to isolate documents. See `reference/session-registry.md` for the full session management system.

See `reference/session-registry.md` for the canonical document naming convention (`RNNN | ` prefix table and session lifecycle).

## User Experience

The structured output workflow is **agent-driven**. The user never writes YAML or JSON. Here's what the user actually does:

### What the User Sees

1. **Chat with agent** — "I need to compare 15 vector databases"
2. **Agent asks questions** — "What fields matter most? Pricing, performance, or ease of use?"
3. **Agent generates outline** — Shows list: "Here are the 15 databases I'll research. Look good?"
4. **User approves** — "Yes, but add Redis Vector"
5. **Agent researches** — "Done with 5 of 15. Here's what I found so far..." [shows Jot link]
6. **User checks progress** — Clicks Jot link, sees results, adds comment: "Make sure to check pricing for enterprise"
7. **Agent finishes** — "All 15 done! Here's your report:" [Jot link]
8. **User shares report** — Sends Jot link to team

### What the Agent Handles (Invisible to User)

- Writing `outline.yaml` and `fields.yaml`
- Running searches for each item
- Saving results as JSON
- Validating coverage
- Generating the final report

## Workflow

### Phase 1: Planning (Same as Standard Research)

Use the standard research planning framework (chat or Jot collaborative planning) to clarify:
- Topic and decision context
- Deliverable shape (now: structured comparison report)
- Stakes

### Phase 2: Outline Generation

Generate `outline.yaml` defining what to research:

```yaml
topic: "AI Coding Assistants 2025"
items:
  - name: "GitHub Copilot"
    category: "IDE Extension"
    description: "Microsoft/GitHub's AI coding assistant"
  - name: "Cursor"
    category: "AI-First IDE"
    description: "VSCode fork with built-in AI"
  - name: "Windsurf"
    category: "AI-First IDE"
    description: "Codeium's agentic IDE"
  # ... more items

execution:
  batch_size: 3
  items_per_agent: 1
  output_dir: "./results"
```

**Stored as Jot document** with `view` access for user monitoring.

### Phase 3: Field Definition

Generate `fields.yaml` defining what to collect for each item:

```yaml
field_categories:
  - category: "Basic Info"
    fields:
      - name: "company"
        description: "Company or organization behind the tool"
        detail_level: brief
        required: true
      - name: "release_date"
        description: "Initial release date"
        detail_level: brief
        required: false
  - category: "Technical Features"
    fields:
      - name: "underlying_model"
        description: "AI model used (e.g., GPT-4, Claude, custom)"
        detail_level: moderate
        required: true
      - name: "context_window"
        description: "Maximum context window size"
        detail_level: moderate
        required: false
  - category: "Business"
    fields:
      - name: "pricing"
        description: "Pricing model and tiers"
        detail_level: detailed
        required: true
      - name: "market_share"
        description: "Estimated market share or user base"
        detail_level: moderate
        required: false

uncertain: []  # Auto-populated during deep research
```

**Stored as Jot document** with `view` access.

### Phase 4: Deep Research (Per-Item JSON)

For each item, dispatch search skill to produce structured JSON. Items are processed in **batches** for efficiency and progress tracking.

#### Batch Configuration

The outline defines how items are processed:

```yaml
execution:
  batch_size: 3          # How many items to research in parallel
  items_per_agent: 1     # How many items each subagent handles
  resume: true           # Skip already-completed items on restart
```

**Batch size guidelines:**
- **1-3 items**: `batch_size: 1` (sequential, easier to monitor)
- **4-9 items**: `batch_size: 2-3` (moderate parallelism)
- **10+ items**: `batch_size: 3-5` (maximum parallelism)

#### Progress Tracking

The agent reports progress after each batch:

```
Batch 1/5 complete (items 1-3 of 15)
✓ GitHub Copilot
✓ Cursor
✓ Windsurf

Next: Batch 2/5 (items 4-6): Codeium, Tabnine, Replit
```

Progress is also visible in Jot — each completed item appears as a document.

#### Per-Item JSON Output

```json
{
  "name": "GitHub Copilot",
  "category": "IDE Extension",
  "company": "Microsoft/GitHub",
  "release_date": "2021-06",
  "underlying_model": "GPT-4 (varies by tier)",
  "context_window": "128k tokens",
  "pricing": "$10/month individual, $19/month business, $39/month enterprise",
  "market_share": "~40% of AI coding assistant market (est. 2025)",
  "uncertain": ["market_share"]
}
```

**Each item stored as separate Jot document** with:
- Title: `RNNN | Result: [Item Name]` (where RNNN is the session ID)
- Content: JSON in code block + summary in markdown
- Share access: `comment` (for stakeholder review)

> See `reference/session-registry.md` for session ID management.

### Phase 5: Report Generation

Compile all per-item JSONs into final markdown report:

```markdown
# Research Report: AI Coding Assistants 2025

## Table of Contents
1. [GitHub Copilot](#github-copilot) — Company: Microsoft | Model: GPT-4
2. [Cursor](#cursor) — Company: Anysphere | Model: Claude/GPT-4
3. [Windsurf](#windsurf) — Company: Codeium | Model: Custom

## Summary Comparison

| Tool | Company | Model | Pricing | Market Share |
|------|---------|-------|---------|--------------|
| GitHub Copilot | Microsoft | GPT-4 | $10-39/mo¹ | ~40%² |
| Cursor | Anysphere | Claude/GPT-4 | $20/mo³ | Growing⁴ |
| Windsurf | Codeium | Custom | $15/mo⁵ | Emerging⁶ |

## Detailed Findings

### GitHub Copilot
**Company:** Microsoft/GitHub
**Release:** 2021-06
...

### Cursor
...

## Sources and References

### Primary Sources
1. [GitHub, "Copilot Pricing"](https://github.com/features/copilot#pricing) — Individual and business tier pricing
2. [GitHub, "Copilot Documentation"](https://docs.github.com/en/copilot) — Market share estimates from GitHub blog
3. [Cursor, "Pricing Plans"](https://cursor.com/pricing) — Pro and business pricing
4. [Cursor, "Blog"](https://cursor.com/blog) — Growth metrics and user base
5. [Codeium, "Pricing"](https://codeium.com/pricing) — Windsurf pricing tiers
6. [Codeium, "About"](https://codeium.com/about) — Company info and market position

### Source Quality Notes
- **High confidence**: Official pricing pages (sources 1, 3, 5)
- **Medium confidence**: Market share estimates (sources 2, 4, 6) — based on company claims and industry analysis
```

**Stored as Jot document** with `comment` access for final review.

## Jot Integration Commands

### Creating Outline Document

```bash
jot local create "RNNN | Outline: [Topic]"
jot local update <id> markdown "```yaml\n[outline.yaml content]\n```"
jot local update <id> shareAccess view
```

### Creating Fields Document

```bash
jot local create "RNNN | Fields: [Topic]"
jot local update <id> markdown "```yaml\n[fields.yaml content]\n```"
jot local update <id> shareAccess view
```

> Replace `RNNN` with the actual session ID. See `reference/session-registry.md`.

### Creating Per-Item Result Document

```bash
jot local create "RNNN | Result: [Item Name]"
jot local update <id> markdown "# RNNN | Result: [Item Name]

## JSON Data
\`\`\`json
[json content]
\`\`\`

## Summary
[2-3 sentence summary of key findings]

## Sources and References

### Primary Sources
1. [Author/Org, \"Title\"](URL) — [What this contributed]
2. [Company, \"Page Name\"](URL) — [What info came from here]

### Secondary Sources
3. [Blog, \"Analysis\"](URL) — [Context on reliability]
4. [Reddit, r/subreddit, \"Discussion\"](URL) — [Community sentiment]

### Source Quality
- **High confidence**: [Authoritative, corroborated sources]
- **Medium confidence**: [Single-source or less authoritative]
- **Low confidence**: [Speculative or unverified]"
jot local update <id> shareAccess comment
```

### Creating Final Report Document

```bash
jot local create "RNNN | Report: [Topic]"
jot local update <id> markdown "[full report markdown]"
jot local update <id> shareAccess comment
```

> **Note:** Replace `RNNN` with the actual session ID (e.g., `R001`). See `reference/session-registry.md` for session management.

## Validation

Use `validate_json.py` to ensure per-item JSONs cover all defined fields:

```bash
python skills/research/tools/validate_json.py \
  --fields fields.yaml \
  --dir ./results
```

Validation checks:
- All required fields present
- Coverage rate per item
- Uncertain fields properly marked
- Extra fields flagged

## Resume Support

Structured output supports resuming interrupted research. Since all results are stored in Jot, progress persists across sessions.

### How Resume Works

1. **Session crashes or user stops after batch 3 of 5**

2. **Next session, agent checks existing results:**
   ```bash
   # Filter by session prefix to avoid mixing projects
   jot local list | grep "R001 | Result:"
   # Shows: R001 | Result: GitHub Copilot, R001 | Result: Cursor, R001 | Result: Windsurf
   # Missing: R001 | Result: Codeium, R001 | Result: Tabnine, ...
   ```

3. **Agent skips completed items** — Compares outline against existing Jot documents matching the session prefix

4. **Agent continues with remaining** — Dispatches research only for missing items:
    ```
    Resuming R001: 3 of 15 items already complete
    Continuing with item 4: Codeium
    ```

### Resume Configuration

Enable resume in the outline:

```yaml
execution:
  resume: true           # Skip completed items on restart
  resume_from: 0         # Start from item N (0 = auto-detect)
```

**Auto-detect resume:** The agent automatically finds the last completed item by checking Jot documents.

**Manual resume:** If you want to re-research specific items, set `resume_from` to that item index.

### User Experience

**User:** "My computer crashed yesterday while researching the 15 vector databases. Where did we leave off?"

**Agent:**
> "No problem! I can see we completed 10 of 15 items in session R001 before the crash. Here's what we have: [Jot link]. I'll continue with the remaining 5: Marqo, Vespa, Typesense, Meilisearch, and ScaNN."

**Agent (after checking R001 documents):**
> "Found 10 completed items in Jot for session R001. Resuming with item 11: Marqo..."

**User:** "Actually, can you re-research Pinecone? I think the pricing changed."

**Agent:**
> "Sure! I'll re-research Pinecone in session R001 and then continue with the remaining items."

The agent deletes the old R001 | Result: Pinecone document and re-runs the search, then continues with items 11-15.

## Comparison with Direct Chat Output

| Aspect | Direct Chat | Structured Output |
|--------|-------------|-------------------|
| Best for | 1-5 items, quick decisions | 10+ items, deep comparison |
| Persistence | Session-only | Persistent Jot documents |
| Collaboration | Real-time chat | Async document comments |
| Review | Immediate | Staged (outline → fields → results → report) |
| Resume | Not supported | Full resume support |
| Output format | Conversation | Structured report with TOC |

## Anti-Patterns

- **Don't use for simple research** — Chat output is faster for <5 items
- **Don't skip validation** — Always run validate_json.py before report generation
- **Don't forget Jot sharing** — Documents need proper access for collaboration
- **Don't mix modes** — If using structured output, keep all artifacts in Jot

## Example: Complete Structured Research Workflow

**User:** "I need to compare 15 vector databases for our platform"

**Agent (in chat):**
> "I'll research 15 vector databases for you. First, let me create a list of what to research."

**Agent (creates outline in Jot, shows user):**
> "Here are the 15 databases I'll research: Pinecone, Weaviate, Milvus, Chroma, pgvector, Redis Vector, Qdrant, Vespa, Typesense, Meilisearch, Elasticsearch, OpenSearch, Faiss, Annoy, ScaNN. Does this look right?"

**User:**
> "Yes, but also add Marqo"

**Agent:**
> "Added Marqo. Now researching... I'll update you as I go."

**Agent (after 5 items):**
> "Done with 5 of 16. You can check progress here: [Jot link]. Let me know if you want me to focus on anything specific."

**User (clicks Jot link, sees results, adds comment):**
> "Make sure to check enterprise pricing for all of them"

**Agent (reads comment, adjusts research):**
> "Got it — I'll make sure to capture enterprise pricing tiers."

**Agent (all done):**
> "All 16 databases researched! Here's your final report: [Jot link]. You can share this link with your team."

**User (shares Jot link with team):**
> Team reviews report, adds comments with questions

**Agent (responds to team comments):**
> "Good catch — I missed Redis Vector's enterprise SLA. Let me check that."

**User gets:** Complete research report, no file editing needed, full team collaboration.
