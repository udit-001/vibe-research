# Search Skill Integration Guide

This reference defines how the research skill delegates search execution to the search skill (Exa Research Orchestrator).

## When to Delegate

**Always delegate search execution to the search skill.** The research skill handles planning and scoping; the search skill handles execution. This separation keeps each skill focused and leverages the search skill's subagent orchestration.

## How to Delegate

### 1. Load the Search Skill

Use the skill tool to activate the search skill:

```
skill:search
```

This loads the Exa Research Orchestrator with all its reference files and subagent dispatch capabilities.

### 2. Structure Your Handoff

Pass a structured research brief that includes:

```
**Research Brief for Search Skill**

**Topic:** [Clear, focused research question]
**Decision Context:** [What choice or action this research supports]
**Deliverable:** [Expected output format — comparison table, recommendation, report, etc.]
**Stakes:** [Low / Moderate / High]

**Search Angles:** [5-10 distinct angles, e.g.:]
1. Overview and fundamentals of [topic]
2. Recent developments and trends in [topic] (last 6-12 months)
3. Leading alternatives and competitors
4. Real-world usage and case studies
5. Common failure modes and criticisms
6. Performance benchmarks and comparisons
7. Security considerations
8. Community adoption and ecosystem health
9. Integration patterns and best practices
10. Future roadmap and deprecation risks

**Domain Context:**
- [Any relevant technical constraints, preferred sources, or exclusions]
- [Specific companies, people, or papers to include/exclude]
- [Time range if relevant]

**Special Instructions:**
- [Any specific filtering needs]
- [Source quality requirements]
- [Output format preferences beyond the deliverable shape]
```

### 3. Let the Orchestrator Work

The search skill will:
- Assess complexity and decide subagent strategy
- Dispatch parallel subagents with Exa searches
- Compile, deduplicate, and validate results
- Return structured findings

**Do not micromanage subagent dispatch** — the search skill's orchestrator is optimized for this.

### 4. Receive and Process Results

The search skill returns:
- Compiled findings with source counts
- Structured data or narrative synthesis
- Coverage notes and gap identification

**Your job as the research skill:**
- Map findings back to the original decision context
- Apply the appropriate output template
- Add your own analysis and recommendations
- Identify any follow-up questions for the user

## Integration Patterns

### Pattern A: Single-Pass Research
For straightforward topics with clear scope:
1. Plan with research skill (Steps 1-3)
2. Hand off to search skill once
3. Synthesize results into final output

### Pattern B: Multi-Pass Research
For complex topics requiring iterative exploration:
1. Plan with research skill
2. Hand off to search skill — Pass 1: Landscape scan
3. Review results, refine angles based on findings
4. Hand off to search skill — Pass 2: Deep dives on promising directions
5. Hand off to search skill — Pass 3: Counter-perspective and validation
6. Synthesize all passes into final output

### Pattern C: Vocabulary-First Research
For unfamiliar domains:
1. Hand off to search skill: "Quick vocabulary scan for [topic]"
2. Review terminology and key concepts
3. Plan refined research with proper vocabulary
4. Execute full research with search skill

### Pattern D: Technical Evaluation
For library/framework comparisons:
1. Plan with research skill using `reference/technical-research.md`
2. Hand off to search skill with technical angles:
   - Core capabilities and features
   - Integration patterns and compatibility
   - Performance benchmarks
   - Community health and maintenance
   - Security track record
   - Migration experiences
3. Synthesize using Technical Recommendation Format

### Pattern E: GitHub-Specific Research
For repository analysis:
1. Plan with research skill using `reference/github-research.md`
2. Hand off to search skill with GitHub angles:
   - Repository activity and maintenance signals
   - Issue patterns and resolution rates
   - Community discussions and alternatives
   - Integration examples and tutorials
3. Supplement with direct GitHub API calls if needed
4. Synthesize using appropriate template

## Communication Between Skills

### From Research → Search
- **Always include:** Topic, decision context, deliverable shape, stakes
- **Include when helpful:** Search angles, domain constraints, special instructions
- **Keep it concise:** The search skill has its own orchestration logic

### From Search → Research
- The search skill returns compiled, deduplicated results
- Review coverage notes for gaps
- Ask for follow-up searches if needed
- Treat search results as input to your synthesis, not final output

## Anti-Patterns

- **Don't bypass the search skill** by running searches directly — you lose subagent orchestration and token isolation
- **Don't re-plan searches inside the search skill** — trust its complexity assessment
- **Don't duplicate search work** — if the search skill already covered an angle, don't re-run it
- **Don't ignore coverage gaps** — if the search skill notes missing angles, address them

## Example Complete Workflow

**User:** "I need to choose between Next.js and Remix for our new SaaS dashboard"

**Research Skill (Steps 1-3):**
- Topic: Framework comparison for SaaS dashboard
- Decision: Pick frontend framework
- Deliverable: Comparison table + recommendation
- Stakes: High (architectural commitment)
- Search angles formed

**Research Skill → Search Skill:**
```
skill:search

**Research Brief:**
**Topic:** Next.js vs Remix for SaaS dashboard (2025-2026)
**Decision Context:** Choosing frontend framework for new SaaS product
**Deliverable:** Comparison table + recommendation with confidence level
**Stakes:** High — architectural commitment, team will use for 2+ years

**Search Angles:**
1. Next.js App Router real-world performance and adoption in 2025
2. Remix v2+ production experiences and case studies
3. Next.js vs Remix performance benchmarks (recent)
4. Common complaints and migration stories from Next.js to Remix
5. Common complaints and migration stories from Remix to Next.js
6. SaaS-specific integration patterns (auth, data fetching, real-time)
7. Ecosystem maturity: plugins, hosting, deployment options
8. Team productivity and learning curve comparisons
9. Security considerations and CVE history
10. Long-term viability and vendor backing

**Domain Context:**
- Target: Modern SaaS dashboard with real-time features
- Team: Experienced with React, limited backend Node.js experience
- Deployment: Vercel preferred but open to alternatives
```

**Search Skill:** Executes, returns compiled findings

**Research Skill:** Synthesizes into Technical Recommendation Format, presents to user with confidence level and trade-offs.
