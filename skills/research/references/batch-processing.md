# Batch Processing and Progress Tracking

This reference defines how the research skill processes large numbers of items efficiently with resume support.

## Why Batch Processing Matters

Without batches:
- Researching 20 items sequentially takes hours
- No visibility into progress
- One failure stops everything
- Can't resume if interrupted

With batches:
- Parallel processing reduces total time
- Progress updates after each batch
- Isolated failures don't stop other items
- Resume from any point

## Batch Configuration

### Default Settings

The agent automatically configures batches based on item count:

| Items | Batch Size | Items/Agent | Estimated Time* |
|-------|-----------|-------------|-----------------|
| 1-3   | 1         | 1           | 5-15 min        |
| 4-9   | 2-3       | 1           | 15-30 min       |
| 10-20 | 3-5       | 1           | 30-60 min       |
| 20+   | 5         | 1-2         | 60+ min         |

*Assuming 5 min per item with parallel search

### Custom Configuration

Advanced users can customize batches in the outline:

```yaml
execution:
  batch_size: 3          # Items per batch
  items_per_agent: 1     # Items each subagent handles
  resume: true           # Enable resume support
  resume_from: 0         # Start from item index (0 = auto)
  
  # Optional: Override defaults for specific items
  overrides:
    - item: "Complex Tool"
      batch_size: 1      # Research alone (needs more depth)
    - item: "Simple Tool"
      items_per_agent: 2 # Can research with another simple item
```

## Progress Tracking

### Agent Reports Progress

After each batch, the agent reports:

```
✅ Batch 2/5 complete

Completed (6/15):
  ✓ GitHub Copilot
  ✓ Cursor
  ✓ Windsurf
  ✓ Codeium
  ✓ Tabnine
  ✓ Replit

In progress:
  ⏳ Sourcegraph Cody (batch 3/5)
  ⏳ Amazon CodeWhisperer (batch 3/5)
  ⏳ JetBrains AI (batch 3/5)

Remaining (6):
  ⏸️ Continue.dev
  ⏸️ Supermaven
  ⏸️ Aider
  ⏸️ Lovable
  ⏸️ v0.dev
  ⏸️ Bolt

ETA: ~20 minutes remaining
```

### User Checks Progress

The user can check progress anytime:

**In chat:**
> User: "How's the research going?"
> Agent: "6 of 15 items complete. Currently researching Sourcegraph Cody, Amazon CodeWhisperer, and JetBrains AI. About 20 minutes left. View progress: [Jot link]"

**In Jot:**
- Each completed item appears as a document
- Documents sorted by completion time
- Click any document to review results

### Progress Visualization in Jot

The agent maintains a progress document in Jot with session namespacing:

```markdown
# R001 | Progress: AI Coding Assistants 2025

## Status: In Progress (6/15 complete)

### Completed ✅
1. [GitHub Copilot](link) — 2025-01-15 10:30
2. [Cursor](link) — 2025-01-15 10:35
3. [Windsurf](link) — 2025-01-15 10:40
4. [Codeium](link) — 2025-01-15 10:45
5. [Tabnine](link) — 2025-01-15 10:50
6. [Replit](link) — 2025-01-15 10:55

### In Progress ⏳
7. Sourcegraph Cody — Started 10:56
8. Amazon CodeWhisperer — Started 10:56
9. JetBrains AI — Started 10:56

### Pending ⏸️
10. Continue.dev
11. Supermaven
12. Aider
13. Lovable
14. v0.dev
15. Bolt

---

**Session:** R001
**Started:** 2025-01-15 10:30
**Estimated completion:** 2025-01-15 11:20
**Last updated:** 2025-01-15 10:56
```

> **Session namespacing:** The `R001 | ` prefix ensures this progress document is isolated from other research projects. See `reference/session-registry.md` for session management.

## Resume Workflow

### Automatic Resume

When research is interrupted (crash, user stops, timeout):

1. **Next session, user says:**
   > "Continue the research we started yesterday"

2. **Agent detects existing sessions:**
   ```bash
   # Read registry to find active sessions
   jot local list | grep "Research Session Registry"
   ```

3. **If multiple active sessions, agent asks:**
   > "You have 2 active research projects: R001 (Vector DBs, 62% complete) and R002 (AI Assistants, planning). Which would you like to continue?"

4. **Agent detects existing progress for the selected session:**
   ```bash
   # Filter by session prefix to avoid mixing projects
   jot local list | grep "R001 | Result:"
   # Finds 6 completed items
   ```

5. **Agent reports status:**
   > "Found 6 completed items in session R001. Resuming with item 7: Sourcegraph Cody. I'll skip the completed items and continue where we left off."

6. **Agent continues from batch 3/5**

> See `reference/session-registry.md` for full session management details.

### Manual Resume Controls

The user can control resume behavior:

**Restart specific item:**
> User: "Re-research GitHub Copilot — I think pricing changed"
> Agent: "Deleting old GitHub Copilot result and re-researching..."

**Skip items:**
> User: "Skip Amazon CodeWhisperer — we're not considering it anymore"
> Agent: "Removing Amazon CodeWhisperer from outline. Continuing with remaining 14 items..."

**Change batch size mid-research:**
> User: "Can you research the remaining items faster?"
> Agent: "Increasing batch size from 3 to 5. This will use more parallel searches but finish sooner."

## Error Handling

### Individual Item Failure

If one item in a batch fails:

```
⚠️ Batch 3/5 partial failure

✅ Completed:
  ✓ Sourcegraph Cody
  ✓ JetBrains AI

❌ Failed:
  ✗ Amazon CodeWhisperer (search timeout)

Retrying Amazon CodeWhisperer in next batch...
```

The agent:
1. Notes the failure
2. Retries the item in the next batch
3. Continues with other items
4. Reports the issue to user

### Batch Failure

If an entire batch fails:

```
❌ Batch 3/5 failed

Error: Search skill timeout (all 3 items)

Retrying with smaller batch size (2 items)...
```

The agent:
1. Reduces batch size
2. Retries failed items
3. Reports adjustment to user

## Best Practices

### For Agents

- **Start with small batches** — Batch size 1-2 for first few items to validate approach
- **Report every batch** — Don't go silent for 30 minutes
- **Update progress document** — Keep Jot progress doc current
- **Handle failures gracefully** — Retry failed items, don't stop everything
- **Validate before report** — Run validation after all items complete

### For Users

- **Don't panic if interrupted** — Progress is saved in Jot
- **Review completed items** — Check early results to catch issues
- **Adjust scope mid-research** — Add/remove items via chat
- **Share progress links** — Send Jot links to teammates for early feedback

## Anti-Patterns

- **Giant batches** — Batch size >5 risks timeouts and makes failures expensive
- **No progress updates** — User thinks research is stuck
- **Not using resume** — Re-researching completed items wastes tokens
- **Ignoring failures** — Failed items should be retried, not silently dropped
- **No progress document** — User can't check status without asking agent

## Example: Full Batch Workflow

**User:** "Research 20 AI coding assistants for me"

**Agent:**
> "That's a large research task. I'll process them in batches of 5 for efficiency. Here's the plan: [Jot link]"

**Batch 1/4:**
```
🚀 Starting batch 1/4 (items 1-5)
Researching: GitHub Copilot, Cursor, Windsurf, Codeium, Tabnine
```

**5 minutes later:**
```
✅ Batch 1/4 complete

All 5 items researched successfully.
Progress: [Jot link]

Starting batch 2/4 (items 6-10)...
```

**User (checks Jot):**
> "The Cursor pricing looks wrong — can you double-check?"

**Agent:**
> "Re-researching Cursor pricing now..."

**Batch 2/4:**
```
✅ Batch 2/4 complete
Progress: 10/20 items done
```

**Session crashes after batch 2**

**Next day:**
**User:** "Continue yesterday's research"

**Agent:**
> "Found session R001 with 10 completed items from yesterday. Resuming with batch 3/4 (items 11-15)..."

**Batch 3/4:**
```
✅ Batch 3/4 complete
Progress: 15/20 items done
```

**Batch 4/4:**
```
✅ Batch 4/4 complete
All 20 items researched!

Validating results... ✓
Generating report... ✓

Final report: [Jot link]
```

**User:** "Great! I'll share this with my team."
