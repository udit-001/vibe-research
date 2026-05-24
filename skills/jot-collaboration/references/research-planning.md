# Research Planning with Jot

This reference defines how jot-collaboration works when invoked by the research skill for collaborative planning.

## Research Planning Mode

When the research skill loads `skill:jot-collaboration`, it enters **research planning mode**. In this mode:

- Documents are structured as **Research Plans** with specific sections
- Comments are interpreted as **feedback on research scope and approach**
- Thread resolution signals **readiness to proceed** with search execution
- The research skill extracts the **final brief** from the resolved document

## Document Structure

Research planning documents MUST include these sections:

### Required Sections

1. **Research Focus** — One-sentence objective
2. **Possible Scopes** — 2-3 options (A, B, C) with descriptions
3. **Clarifying Questions** — Structured questions about:
   - Decision context (what choice this supports)
   - Deliverable shape (output format)
   - Stakes assessment (low/moderate/high)
4. **Discussion** — Open area for additional comments

### Optional Sections

- **Constraints** — Technical, budget, or timeline constraints
- **Background** — Context the user has already provided
- **Timeline** — When research results are needed

## Comment Interpretation

When reading comments in research planning mode:

### On Scope Options (A, B, C)
- **"I prefer Option X"** or **"Let's go with X"** → Selected scope, resolve thread
- **"Can we combine X and Y?"** → Propose hybrid scope, keep thread open
- **"None of these cover Z"** → Add new scope option, ask for feedback

### On Clarifying Questions
- **Direct answer** → Update document with answer, resolve thread
- **"I'm not sure"** → Ask follow-up question, keep thread open
- **"This doesn't apply"** → Note exception, resolve thread

### On Stakes Assessment
- **Selected stakes level** → Confirm and calibrate research depth
- **"Higher than that"** → Upgrade stakes, adjust research approach
- **Disagreement on stakes** → Discuss implications, resolve before proceeding

### On Discussion Section
- **New requirements** → Add to constraints or scope
- **Questions about process** → Explain workflow
- **Timeline concerns** → Adjust planning approach

## Consensus Detection

Research planning is complete when:

1. **Scope selected** — One option chosen (or hybrid agreed)
2. **All clarifying questions answered** — No open threads on required sections
3. **Stakes confirmed** — Agreement on risk level
4. **No blocking concerns** — All threads either resolved or acknowledged

## Extracting the Final Brief

Once consensus is reached, extract these fields for search delegation:

```
**Research Brief for Search Skill**

**Topic:** [From Research Focus section]
**Decision Context:** [Answer to clarifying question 1]
**Deliverable:** [Answer to clarifying question 2]
**Stakes:** [Answer to clarifying question 3]

**Search Angles:** [Generate 5-10 based on selected scope]
1. [Angle 1]
2. [Angle 2]
...

**Domain Context:** [From Constraints and Background sections]
```

## Workflow Example

### Step 1: Create Document

```bash
jot local create "Research Plan: Vector Database Selection"
jot local update <id> markdown "# Research Plan: Vector Database Selection

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

## Discussion
[Space for open discussion]"

jot local update <id> shareAccess comment

# Auto-open in browser (automatic in research planning mode)
start http://localhost:3210/n/<id>  # Windows
# open http://localhost:3210/n/<id>  # macOS
# xdg-open http://localhost:3210/n/<id>  # Linux
```

### Step 2: Read Comments and Respond

```bash
jot local read <id>
# Review comments, identify which threads need responses

jot local reply <id> <thread-id> <message-id> "Good point. I'll add that as a constraint."
```

### Step 3: Update Document Based on Feedback

```bash
jot local edit <id> '[{"oldText":"## Discussion\n[Space for open discussion]","newText":"## Constraints\n- Must be cloud-managed (no self-hosting)\n- Budget: under $500/month at launch\n\n## Discussion\n[Space for open discussion]"}]'
```

### Step 4: Resolve Threads

```bash
jot local resolve <id> <thread-id>
```

### Step 5: Extract and Delegate

Once all threads resolved, extract final brief and delegate to search skill.

## Best Practices for Research Planning

- **Start with 3 scope options** — Gives user meaningful choice without overwhelming
- **Make questions specific** — "What decision?" not "What do you want?"
- **Include stakes assessment** — Calibrates research depth automatically
- **Auto-open the document** — In research planning mode, always open the browser after sharing so the user can start immediately
- **Update document promptly** — Don't let comments sit unanswered
- **Resolve threads explicitly** — Signals progress and keeps document clean
- **Extract formally** — Don't skip the structured brief extraction step

## Anti-Patterns

- **Vague scope options** — "Option A: everything" vs "Option B: nothing"
- **Leading questions** — "You want the fastest option, right?"
- **Ignoring stakes** — All research is not equal; stakes drive depth
- **Proceeding without consensus** — If threads are open, planning isn't done
- **Mixing planning and execution** — Don't start searches before scope is locked
