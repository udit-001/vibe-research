# Research Session Registry

This reference enables running multiple concurrent or sequential research projects with full isolation, tracking, and resume support.

## Problem

Without session management:
- Multiple research projects overwrite each other's Jot documents
- No way to list active research projects
- No way to resume a specific research project
- Progress documents from different projects get mixed together
- Agent can't distinguish which research is which

## Solution: Research Session Registry

A lightweight session tracking system using Jot as the persistent store.

### Core Concepts

| Concept | Description | Example |
|---------|-------------|---------|
| **Session ID** | Unique identifier for a research project | `R001`, `R002` |
| **Session Title** | Human-readable name | "Vector DB Comparison" |
| **Namespace** | Prefix for all documents in a session | `R001 \| ` |
| **Registry** | Master document tracking all sessions | "Research Session Registry" |
| **Status** | Current state of a session | `planning`, `active`, `paused`, `completed` |

## Session Lifecycle

```
Planning → Active → [Paused → Active]* → Completed
    ↓         ↓
 Cancelled  Failed (can resume)
```

### States

| State | Meaning | Can Resume? |
|-------|---------|-------------|
| `planning` | Outline/fields being defined | Yes |
| `active` | Research in progress | Yes (auto-detect) |
| `paused` | User explicitly paused | Yes |
| `completed` | All items researched, report generated | No (archive) |
| `cancelled` | User cancelled before completion | No |
| `failed` | Error stopped research | Yes (retry) |

## Session Registry Document

Stored as a Jot document titled **"Research Session Registry"**.

```markdown
# Research Session Registry

## Active Sessions

### R001 | Vector Database Comparison
- **Status:** active
- **Started:** 2025-01-15 10:30
- **Items:** 16 total, 10 complete, 6 remaining
- **Last activity:** 2025-01-15 11:20
- **Documents:** [Outline](link), [Progress](link), [Report](link)

### R002 | AI Coding Assistants 2025
- **Status:** planning
- **Started:** 2025-01-15 14:00
- **Items:** 15 total, 0 complete
- **Last activity:** 2025-01-15 14:15
- **Documents:** [Outline](link)

## Completed Sessions

### R003 | Next.js vs Remix
- **Status:** completed
- **Started:** 2025-01-14 09:00
- **Completed:** 2025-01-14 11:30
- **Documents:** [Report](link)

## Cancelled Sessions

### R004 | Kubernetes Operators
- **Status:** cancelled
- **Started:** 2025-01-13 16:00
- **Cancelled:** 2025-01-13 16:30
- **Reason:** User pivoted to different topic
```

## Document Naming Convention *(Canonical)*

This is the single source of truth for the `RNNN | ` naming convention. All other reference files defer here.

All documents for a session use the prefix `RNNN | `:

| Document Type | Example Title |
|--------------|---------------|
| Planning | `R001 \| Research Plan: Vector Databases` |
| Outline | `R001 \| Outline: Vector Databases` |
| Fields | `R001 \| Fields: Vector Databases` |
| Per-item result | `R001 \| Result: Pinecone` |
| Progress | `R001 \| Progress: Vector Databases` |
| Report | `R001 \| Report: Vector Databases` |
| Registry | `Research Session Registry` (no prefix — global) |

## Workflow: Starting a New Research Session

### Step 1: Check for Existing Sessions

```bash
# Check if registry exists
jot local list | grep "Research Session Registry"

# If not found, create it
jot local create "Research Session Registry"
jot local update <id> markdown "# Research Session Registry\n\n## Active Sessions\n\n## Completed Sessions\n\n## Cancelled Sessions"
```

### Step 2: Generate Session ID

```bash
# Read registry to find highest existing ID
jot local read <registry-id>

# Generate next ID (R001, R002, ...)
# If no sessions exist: R001
# If R001-R003 exist: R004
```

### Step 3: Create Session Entry

Add to registry:

```markdown
### R005 | [Topic Name]
- **Status:** planning
- **Started:** [timestamp]
- **Items:** [N] total, 0 complete
- **Last activity:** [timestamp]
- **Documents:** (to be added)
```

### Step 4: Create Namespaced Documents

All subsequent documents use the `RNNN | ` prefix:

```bash
jot local create "R005 | Outline: AI Coding Assistants"
jot local create "R005 | Fields: AI Coding Assistants"
# etc.
```

## Workflow: Listing Active Research

### User: "What research do I have in progress?"

**Agent:**
1. Read registry document
2. List active sessions with progress:

```
You have 2 active research projects:

1. **R001 | Vector Database Comparison** (active)
   - 10 of 16 items complete (62%)
   - Last worked on: Jan 15, 11:20 AM
   - [View progress](link)

2. **R002 | AI Coding Assistants 2025** (planning)
   - Outline created, waiting for approval
   - Last worked on: Jan 15, 2:15 PM
   - [View outline](link)
```

## Workflow: Resuming a Specific Session

### User: "Continue my vector database research"

**Agent:**
1. Parse request → identify session R001
2. Read registry entry for R001
3. Check status: `active`, 10 of 16 complete
4. List existing documents:
   ```bash
   jot local list | grep "R001 |"
   ```
5. Read progress document to find last completed item
6. Resume from next item:
   ```
   Resuming R001 | Vector Database Comparison
   Found 10 completed items. Continuing with item 11: Marqo...
   ```

### User: "Continue research" (ambiguous)

**Agent:**
1. List active sessions
2. If only one active: resume it
3. If multiple: ask user which one

## Workflow: Updating Session Status

After each significant action, update the registry:

```bash
# After completing an item
jot local edit <registry-id> '[{"oldText":"- **Items:** 16 total, 10 complete","newText":"- **Items:** 16 total, 11 complete"}]'

# After changing status
jot local edit <registry-id> '[{"oldText":"- **Status:** active","newText":"- **Status:** paused"}]'

# Update last activity
jot local edit <registry-id> '[{"oldText":"- **Last activity:** 2025-01-15 11:20","newText":"- **Last activity:** 2025-01-15 12:00"}]'
```

## Session Isolation Rules

1. **Never mix documents** — All documents for session R001 must start with `R001 | `
2. **Resume only within session** — When resuming, only check documents matching the session prefix
3. **Progress tracking is per-session** — Each session has its own progress document
4. **Registry is global** — One registry document for all sessions

## Commands Reference

### Create New Session

```bash
# 1. Find or create registry
REGISTRY_ID=$(jot local list | grep "Research Session Registry" | head -1 | awk '{print $1}')
if [ -z "$REGISTRY_ID" ]; then
  REGISTRY_ID=$(jot local create "Research Session Registry")
  jot local update "$REGISTRY_ID" markdown "# Research Session Registry\n\n## Active Sessions\n\n## Completed Sessions\n\n## Cancelled Sessions"
fi

# 2. Generate next session ID
# Read registry, find max R number, increment

# 3. Create session entry
jot local edit "$REGISTRY_ID" '[{"oldText":"## Active Sessions","newText":"## Active Sessions\n\n### R001 | Topic\n- **Status:** planning\n- **Started:** 2025-01-15\n- **Items:** 0 total, 0 complete\n- **Last activity:** 2025-01-15\n- **Documents:**"}]'
```

### List Active Sessions

```bash
# Get all documents
jot local list

# Filter by active status in registry
# (Agent reads registry document and parses)
```

### Resume Session

```bash
# Find session documents
jot local list | grep "R001 |"

# Read progress document
jot local read <progress-id>

# Determine next item to research
```

## Anti-Patterns

- **Don't skip the registry** — Always register new sessions
- **Don't reuse session IDs** — Each research gets a unique ID
- **Don't forget to update status** — Registry becomes stale
- **Don't mix sessions in one document** — Each session gets its own documents
- **Don't delete completed sessions** — Move to "Completed" section for history

## Example: Complete Multi-Session Workflow

**User:** "Research vector databases for me"

**Agent:**
1. Checks registry → finds R001 (active, 10/16) and R002 (planning)
2. Creates R003 for new request
3. Creates `R003 | Outline: Vector Databases`
4. Updates registry with R003 entry
5. Proceeds with planning

**User:** "What research do I have?"

**Agent:**
1. Reads registry
2. Reports:
   ```
   Active research:
   - R001 | Vector Database Comparison (62% complete)
   - R002 | AI Coding Assistants (planning phase)
   - R003 | Vector Databases (just started)
   ```

**User:** "Continue R001"

**Agent:**
1. Finds R001 documents via `jot local list | grep "R001 |"`
2. Reads progress: 10 of 16 complete
3. Resumes with item 11: Marqo

**User:** "Mark R002 as cancelled"

**Agent:**
1. Updates R002 status to `cancelled`
2. Moves R002 from Active to Cancelled section
3. Updates registry
