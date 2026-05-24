---
name: deep-research
description: Interactive research planning framework that teaches agents how to clarify research objectives through iterative questioning before conducting investigation.
license: MIT
---

# Deep Research Skill - Interactive Planning Framework

This skill provides a framework for conducting interactive research planning. Rather than making assumptions about research needs, agents should use this approach to clarify objectives through questioning.

## How to Use This Framework

When a user requests research help, follow this iterative process:

### Step 1: Initial Understanding
Start by asking what the user wants to research, then use the questioning framework below to scope it properly.

### Step 2: Questioning Framework
Use this structure to guide your questioning (similar to the Expert Prompt Creator approach):

```
**Research Focus:**
>{Clear statement of what needs to be researched, based on user input. Don't assume details - we'll refine as we go. Frame as a research objective.}

**Possible Research Scopes:**
{A) [Broader scope - more comprehensive]
 B) [Focused scope - specific aspect]
 C) [Alternative angle - different perspective]}
 
**Surface Assumptions:**
>{State your current understanding of the topic explicitly. If multiple interpretations exist, present them — don't pick silently. Flag what's uncertain or ambiguous. Let the user correct you before you invest effort in the wrong direction.}

**Clarifying Questions:**
{1. What specific decision or action will this research support?
 2. What form should the output take? (comparison table, recommendation, debugging report, etc.)
 3. What level of detail is appropriate given the stakes involved?}
```

### Step 3: Iterative Refinement
After the user responds with their chosen scope and answers to questions:
1. Incorporate their responses directly into the research focus statement
2. Generate new possible scopes and questions based on the updated understanding
3. Repeat until the research plan is clear and actionable

---

## Collaborative Planning Mode (Optional)

For complex research or when the user prefers structured async collaboration, use **Jot** to create a collaborative planning document instead of chat-based iteration.

### When to Use Collaborative Planning

Use Jot-based planning when:
- The research has multiple stakeholders who need to weigh in
- The scope is complex with many interdependent questions
- The user wants to review and comment on specific parts of the plan
- You need to preserve planning context across multiple sessions
- The user prefers document-based collaboration over chat

### How It Works

1. **Create Planning Document** — Use `skill:jot-collaboration` to create a structured research planning document with:
   - Research Focus statement
   - Possible Scopes (A, B, C)
   - Clarifying Questions
   - Decision Context section
   - Deliverable Shape section

2. **Share and Auto-Open** — Set share access to `comment`, then automatically open the document in the user's default browser so they can start commenting immediately

3. **Iterate via Comments** — The user (and teammates) add inline comments on specific questions or scope options

4. **Refine and Resolve** — Read comments, update the document, resolve threads when consensus is reached

5. **Extract Final Plan** — Once all threads are resolved, extract the agreed-upon scope and delegate to search skill

### Example Planning Document Structure

```markdown
# Research Plan: [Topic]

## Research Focus
[Clear objective statement]

## Possible Scopes
**A) [Broader scope]**
[Description]

**B) [Focused scope]**
[Description]

**C) [Alternative angle]**
[Description]

## Clarifying Questions
1. **Decision Context:** What specific decision will this research support?
2. **Deliverable Shape:** What form should the output take?
3. **Stakes:** What happens if this answer is wrong? (Low / Moderate / High)

## Discussion
[Space for inline comments and discussion]
```

For detailed integration patterns, see `reference/jot-integration.md`.
### Step 4: Choose Output Mode

Based on the number of items and complexity, choose the appropriate output mode:

**Direct Chat Output** (default):
- Best for: 1-5 items, quick decisions, conversational exploration
- Process: Delegate to search skill → Synthesize in chat → Present results
- See: `reference/search-integration.md`

**Structured Output** (for large-scale research):
- Best for: 10+ items, competitive analysis, benchmark surveys
- Process: Agent generates outline → Defines fields → Researches each item → Compiles report
- All stored in **Jot** — user reviews via chat and Jot comments, never edits files directly
- See: `reference/structured-output.md`

**Decision criteria:**
- ≤5 items OR need quick answer → Direct chat
- 6-9 items OR moderate complexity → Either mode (ask user preference)
- ≥10 items OR need persistent artifacts → Structured output

### Step 5: Research Execution

#### For Direct Chat Output:

1. **Load the search skill** — Use `skill:search` to activate the Exa Research Orchestrator
2. **Pass your research plan** — Include the clarified scope, decision context, deliverable shape, and stakes
3. **Let the orchestrator handle execution** — The search skill will assess complexity, dispatch subagents, and compile results
4. **Review and synthesize** — Take the compiled results and format them according to the appropriate output template

**Example handoff:**
```
I've clarified the research scope with the user. Please execute the search:
- Topic: [research focus]
- Decision: [what choice this supports]
- Deliverable: [output format needed]
- Stakes: [low/moderate/high]
- Suggested angles: [5-10 search angles from Step 2]
```

#### For Structured Output:

The agent manages all file generation. The user interacts through chat and Jot review.

**Session Setup (for multi-research support):**
1. **Create session** — Use the CLI tool to create a new session (`research_session.py create "Topic" --items N`)
2. **Note session ID** — The CLI returns the auto-assigned ID (R001, R002, ...). All Jot documents use `RNNN | ` prefix (see `reference/session-registry.md` for naming conventions).
3. **Use namespaced titles** — All documents prefixed with `RNNN | ` (e.g., `R001 | Outline: Topic`)

**Research Workflow:**
1. **Generate outline** — Agent lists all research items, shows user in chat for approval
2. **Define fields** — Agent asks what information matters, creates field definitions
3. **Store in Jot** — Agent creates Jot documents for outline and fields (user views, doesn't edit)
4. **Get user approval** — User reviews outline/fields via chat or Jot comments
5. **Configure batches** — Agent sets batch size based on item count (1-5 per batch)
6. **Update progress** — Set total items: `research_session.py progress <ID> --total N`
7. **Deep research** — For each batch, agent dispatches parallel searches and saves results
   - Reports progress after each batch: "Done with 5 of 15..."
   - Update completed count: `research_session.py progress <ID> --completed N`
   - Each result stored as Jot document with session prefix
8. **Resume support** — If interrupted, run `research_session.py list` to find session, `research_session.py show <ID>` for progress, skip completed items
9. **Validate** — Agent runs validation to check coverage
10. **Generate report** — Agent compiles all results into markdown report in Jot
11. **Mark complete** — `research_session.py status <ID> completed`
12. **Final review** — User receives Jot link to share with stakeholders

For detailed structured output workflow, see `reference/structured-output.md`.

For batch processing and progress tracking, see `reference/batch-processing.md`.

For search delegation guidance, see `reference/search-integration.md`.

For collaborative planning with Jot, see `reference/jot-integration.md`.

For managing multiple research sessions, see `reference/session-registry.md`.

## Core Research Methodology (References)

For the actual research execution, consult:
- `reference/technical-research.md` - For technical evaluations
- `reference/github-research.md` - For GitHub-specific work
- `reference/search-integration.md` - **How to delegate searches to the search skill**
- `reference/jot-integration.md` - **How to use Jot for collaborative planning**
- `reference/structured-output.md` - **How to use structured file-based output for large-scale research (10+ items)**
- `reference/batch-processing.md` - **How to process items in batches with progress tracking and resume support**
- `reference/session-registry.md` - **How to manage multiple concurrent research sessions with unique IDs and namespacing**
- Main skill sections below for general research operations

## Multi-Research Session Management

When the user has multiple research projects, use the **CLI tool** to track and isolate them.

### When to Use Session Management

Use session management when:
- The user has multiple active research projects
- Research spans multiple days and needs resume support
- Different research topics need isolated document namespaces
- The user wants to switch between research projects

### How It Works

The CLI tool (`skills/research/tools/research_session.py`) manages sessions in `.research/sessions.json` with no external dependencies beyond `click` and `rich`.

### Quick Commands

**List all sessions:**
```bash
python3 skills/research/tools/research_session.py list
python3 skills/research/tools/research_session.py list --status active  # filter by status
```

**Create a new session:**
```bash
python3 skills/research/tools/research_session.py create "Research Topic" --items 15
```

**Show session details:**
```bash
python3 skills/research/tools/research_session.py show R001
```

**Update status or progress:**
```bash
python3 skills/research/tools/research_session.py status R001 active
python3 skills/research/tools/research_session.py progress R001 --completed 5
```

**Add outline items from JSON:**
```bash
python3 skills/research/tools/research_session.py add-outline R001 '[{"name": "Item 1", "category": "Cat A"}]'
```

**Create and link Jot documents (agent runs these automatically):**
```bash
python3 skills/research/tools/research_session.py jot-create R001 "Outline"
python3 skills/research/tools/research_session.py jot-create R001 "Fields"
# Creates "R001 | Outline: <title>" and "R001 | Fields: <title>" in Jot,
# stores returned doc IDs in sessions.json automatically — no manual doc linking needed
```

**Export or delete a session:**
```bash
python3 skills/research/tools/research_session.py export R001
python3 skills/research/tools/research_session.py delete R001  # prompts for confirmation
```

**View statistics:**
```bash
python3 skills/research/tools/research_session.py stats
```

**Start new research (auto-assigns session ID):**
```
User: "Research vector databases"
Agent: Runs `research_session.py create "Vector Databases" --items 10`
        → Creates R005, then creates R005 | Outline, etc.
```

**Resume specific research:**
```
User: "Continue R001"
Agent: Runs `research_session.py show R001` to see progress, resumes
```

**Switch between research:**
```
User: "What research do I have?"
Agent: Runs `research_session.py list` to show all sessions

User: "Continue the vector database one"
Agent: Runs `research_session.py list | grep -i vector` to find R001, resumes it
```

For full session management details, see `reference/session-registry.md`.

## Research Operations

### Quick Research
**Fast answers for straightforward questions:**
1. Load the search skill (`skill:search`)
2. Pass the question with context: "Quick research needed — low stakes, single angle"
3. Let the search skill run one targeted search
4. Reply with direct answers, key facts, important caveats, suggested next step

Use this for low-stakes questions where a single search angle is sufficient.

---

### Deep Research Process
1. **Restate scope explicitly before searching:**
   - **Topic:** What is being investigated?
   - **Decision:** What choice or action must this research support (e.g., "pick a library," "decide whether to migrate," "explain a failure mode to the team").
   - **Deliverable shape:** What use will you retain? (e.g., comparison table, recommendation memo, ranked list of flaws, debugging hypothesis). Pick the matching output template before guessing.
   - **Stakes:** What happens if this answer is wrong? Use this to calibrate effort:
     - **Low-stakes** (e.g., naming a function, picking a log format): 1-2 searches, quick scan.
     - **Moderate-stakes** (e.g., shape of a public API, schema decision): deeper coverage, 2+ sources per non-trivial claim.
     - **High-stakes** (e.g., choosing a database, signing a vendor, architectural commitment): full depth, primary sources, explicit counter-perspective pass, ≥90% confidence target.
     - If any of these are unclear from the request, ask before searching—the wrong stakes call for the wrong research.

2. **Vocabulary discovery** - learn domain terminology (use search skill with: "Quick vocabulary scan for [topic]")
3. **Form 5-10 distinct search angles** - overview, developments, alternatives, usage, failure modes
4. **Delegate to search skill** - Load `skill:search` and pass:
   - The restated scope (topic, decision, deliverable, stakes)
   - Your 5-10 search angles
   - Any domain-specific context from reference files
   - Let the orchestrator handle parallel subagent dispatch
5. **Review compiled results** - The search skill returns deduplicated, structured findings
6. **Counter-perspective pass** - Ask the search skill: "Run a counter-perspective search on these findings — look for criticisms, limitations, and alternatives"
7. **Stopping checks** - Watch for diminishing returns; ask search skill to validate coverage gaps
8. **Synthesize** into structured output with **mandatory citations** using the appropriate template. Every factual claim must have a source. See `../search/SKILL.md` (Citation Requirements section) for the canonical citation rules.

### Question Templates for Different Research Types

For domain-specific questioning guidance, see `reference/question-templates.md`.

## Anti-Patterns and Troubleshooting

For common failure modes and how to recover when research stalls, see `reference/anti-patterns.md`.

## Important Principles

1. **Never assume details** - Always clarify through questions
2. **Frame everything as a request for information** - Keep the collaborative tone
3. **Update iteratively** - Each user response should refine the research plan
4. **Match depth to stakes** - Low stakes = quick research, High stakes = deep investigation
5. **Focus on actionable output** - Always tie research back to a decision or action
6. **Cite every claim** — Every factual statement must have a source. No exceptions. See `../search/SKILL.md` (Citation Requirements section) for the canonical citation rules.

## Output Templates

For structured output templates (Comparison Output, Standard Research Output, Table-Writing Rules), see `reference/output-templates.md`.

## Getting Started

To begin helping a user with research, first ask: "What would you like to research?"

Then use the questioning framework above to scope the work properly before proceeding with investigation.