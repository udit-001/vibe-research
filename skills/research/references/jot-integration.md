# Jot-Research Integration Guide

This reference defines how the research skill uses jot-collaboration for structured planning workflows.

## When to Use Collaborative Planning

Use Jot-based planning instead of chat-based iteration when:

- **Multiple stakeholders** — Team members need to weigh in on scope or approach
- **Complex scope** — Many interdependent questions that need structured exploration
- **Targeted feedback** — User wants to comment on specific questions or scope options
- **Session persistence** — Planning spans multiple sessions; document preserves context
- **Document preference** — User prefers async document review over real-time chat

## Integration Patterns

### Pattern 1: Full Collaborative Planning (Recommended for Complex Research)

For high-stakes or multi-stakeholder research:

1. **Research skill** creates Jot planning document with:
   - Research Focus
   - 3 Possible Scopes (A, B, C)
   - Clarifying Questions
   - Decision Context prompt
   - Deliverable Shape prompt
   - Stakes assessment prompt

2. **Share and auto-open** — Set `comment` access, then automatically open the document in the user's default browser so they can start commenting immediately

3. **User(s)** add inline comments on:
   - Preferred scope option
   - Answers to clarifying questions
   - Additional constraints or context

4. **Research skill** reads comments and:
   - Updates document with agreed scope
   - Adds follow-up questions as new sections
   - Resolves threads when consensus reached

5. **Repeat** until all threads resolved

6. **Extract** final research brief and delegate to search skill

### Pattern 2: Lightweight Planning (Quick Research)

For moderate-stakes research where user wants structured input but not full collaboration:

1. **Research skill** creates concise Jot document with:
   - Research Focus
   - 2-3 scope options
   - 2-3 key questions

2. **User** reviews and comments with preferences

3. **Research skill** updates once, resolves threads

4. **Delegate** to search skill

### Pattern 3: Stakeholder Review

When research plan needs approval before execution:

1. **Research skill** creates full planning document

2. **Share and auto-open** — Set `comment` access, then automatically open the document in the user's default browser

3. **Collect** feedback via inline comments

4. **Revise** based on feedback

5. **Get** explicit approval (resolve final approval thread)

6. **Execute** research and share results back in same document or new one

## Document Templates

### Template A: Full Research Plan

```markdown
# Research Plan: [Topic]

## Research Focus
> [Clear, one-sentence objective. What are we trying to learn?]

## Possible Scopes

### Option A: [Broader scope]
[Description of what this covers and when to choose it]

### Option B: [Focused scope]
[Description of what this covers and when to choose it]

### Option C: [Alternative angle]
[Description of what this covers and when to choose it]

## Clarifying Questions

### 1. Decision Context
What specific decision or action will this research support?
> [User responds via comment on this line]

### 2. Deliverable Shape
What form should the output take?
- [ ] Comparison table
- [ ] Recommendation memo
- [ ] Ranked list of options
- [ ] Debugging hypothesis
- [ ] Other: ___

### 3. Stakes Assessment
What happens if this answer is wrong?
- [ ] **Low** — Naming, formatting, minor preference
- [ ] **Moderate** — API shape, schema decision, tool selection
- [ ] **High** — Database choice, vendor commitment, architecture

## Discussion
[Space for open discussion and additional comments]
```

### Template B: Quick Planning

```markdown
# Quick Research: [Topic]

## Focus
[One-line objective]

## Options
1. [Scope option 1]
2. [Scope option 2]

## Key Questions
1. [Most important question]
2. [Second question]

## Decision
[To be filled after discussion]
```

## Session Namespacing

When the research skill is managing multiple research projects, all Jot documents use **session namespacing** with the prefix `RNNN | ` (e.g., `R001 | `). Document naming follows the canonical convention in `reference/session-registry.md`.

### Why Namespacing Matters

Without namespacing:
- Multiple research projects overwrite each other's documents
- `jot local list | grep "Research:"` returns mixed results from all projects
- Resume logic can't distinguish which items belong to which research

With namespacing:
- Each research project has isolated documents
- `jot local list | grep "R001 |"` returns only R001 documents
- Resume logic filters by session prefix

## Workflow Commands

### Creating the Planning Document

```bash
# Create document (with session namespacing)
jot local create "RNNN | Research Plan: [Topic]"

# Add structured content
jot local update <id> markdown "[Full template content]"

# Enable comments
jot local update <id> shareAccess comment

# Auto-open in browser (automatic in research planning mode)
# Windows: start http://localhost:3210/n/<id>
# macOS: open http://localhost:3210/n/<id>
# Linux: xdg-open http://localhost:3210/n/<id>
```

> Replace `RNNN` with the actual session ID (e.g., `R001`).

### Reading and Responding to Feedback

```bash
# Read all comments and threads
jot local read <id>

# Reply to a specific comment
jot local reply <id> <thread-id> <message-id> "Response addressing feedback"

# Update document based on feedback
jot local edit <id> '[{"oldText":"original text","newText":"improved text"}]'

# Resolve thread when consensus reached
jot local resolve <id> <thread-id>
```

### Extracting Final Plan

Once all threads are resolved, extract these fields for search delegation:

- **Topic** — From Research Focus section
- **Decision** — From Decision Context answer
- **Deliverable** — From Deliverable Shape selection
- **Stakes** — From Stakes Assessment
- **Search Angles** — Generate 5-10 angles based on agreed scope
- **Session ID** — The RNNN prefix for this research (e.g., R001)

## Communication Between Skills

### Research → Jot Collaboration
- **Trigger:** User requests research + prefers document collaboration OR complex scope detected
- **Action:** Create planning document, share URL
- **Include:** Research focus, scope options, clarifying questions

### Jot Collaboration → Research
- **Trigger:** User adds comments or resolves threads
- **Action:** Read comments, update plan, check if ready to proceed
- **Signal to proceed:** All clarifying questions answered + scope selected

### Research → Search (after Jot planning)
- **Trigger:** Planning document consensus reached
- **Action:** Extract final brief, delegate to search skill
- **Include:** All fields from standard search delegation + link to planning doc for context

## Anti-Patterns

- **Don't force Jot for simple research** — Chat-based iteration is faster for straightforward questions
- **Don't leave threads unresolved** — Resolve or address every comment before proceeding
- **Don't duplicate planning in chat** — If using Jot, keep all planning discussion in the document
- **Don't forget to share** — Document is useless if user can't access it
- **Don't skip extraction** — Always formally extract the final plan before search delegation

## Example: Complete Collaborative Planning Workflow

**User:** "I need to research vector databases for our AI startup. It's a big decision and my CTO wants to review the plan."

**Research Skill:**
1. Detects high stakes + multiple stakeholders → Use collaborative planning
2. Loads `skill:jot-collaboration`
3. Creates planning document:

```markdown
# Research Plan: Vector Database Selection

## Research Focus
Evaluate vector databases for production AI startup use case.

## Possible Scopes
### Option A: Full landscape
Compare all major vector DBs (Pinecone, Weaviate, Milvus, Chroma, pgvector, etc.)

### Option B: Cloud-managed focus
Focus on managed solutions only (Pinecone, Weaviate Cloud, Azure AI Search)

### Option C: Open-source self-hosted
Focus on open-source options (Milvus, Weaviate, Chroma, pgvector)

## Clarifying Questions
### 1. Decision Context
What specific decision will this research support?

### 2. Deliverable Shape
What form should the output take?
- [ ] Comparison table
- [ ] Recommendation memo with ranked options
- [ ] Technical evaluation report

### 3. Stakes Assessment
What happens if this answer is wrong?
- [ ] Low
- [ ] Moderate
- [ ] High — Will be hard to migrate once chosen
```

4. Shares URL with user

**User + CTO:** Add inline comments:
- On Option B: "This is what we want — we need managed solution"
- On Question 1: "Choosing primary vector store for our RAG pipeline"
- On Question 2: "Comparison table + recommendation"
- On Question 3: "High — migration would be painful"

**Research Skill:**
5. Reads comments, updates document with selections
6. Resolves all threads
7. Extracts final brief:
   - Topic: Managed vector databases for RAG pipeline
   - Decision: Choose primary vector store
   - Deliverable: Comparison table + recommendation
   - Stakes: High
   - Search angles: [generates 10 angles focused on managed solutions]

8. Delegates to search skill with full brief

**Search Skill:** Executes research, returns compiled findings

**Research Skill:** Synthesizes into comparison table, presents to user
