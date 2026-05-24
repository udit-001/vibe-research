# Output Templates

Use these templates when synthesizing research findings. Pick the one that matches your deliverable shape.

---

## Comparison Output

Use this template when the deliverable shape is a technology or solution comparison.

### Quick Verdict
[1-2 sentence recommendation – which one wins, for whom]

---

### Detailed Comparison

| **Criterion**       | **Option A**                          | **Option B**                          |
|---------------------|---------------------------------------|---------------------------------------|
| Primary purpose     | ...                                   | ...                                   |
| Architecture        | ...                                   | ...                                   |
| Required depth      | ...                                   | ...                                   |
| Ease of use         | ...                                   | ...                                   |
| Community / stars   | ...                                   | ...                                   |
| Maintenance signal  | ...                                   | ...                                   |
| Latent reliability  | ...                                   | ...                                   |
| Likelihood to fail  | ...                                   | ...                                   |
| Value fit for       | ...                                   | ...                                   |

---

### Critical Analysis
- Where the table's lines matter.
- What's consistent or inconsistent across sources.
- **Citations**: Every claim in this section must reference a source from the Sources section below.

---

### Recommendation
- Default pick for **use case A** ...
- Default pick for **use case B** ...
- Hybrid / split to consensus ...
- **Citations**: Link to supporting sources for each recommendation.

---

## Table-Writing Rules
1. Use Markdown pipe-table syntax: `| col1 | col2 |` with a separator row under the header.
2. Do not wrap the table in code fences; it must be raw Markdown so it renders.
3. One row per criterion, one column per candidate. Never replace the table with bullet lists for candidates.
4. Keep cells to short phrases or one short sentence; long content goes in **Critical Analysis** below the table.
5. Drop rows if they are identical across all candidates.
6. Pick rows that actually differentiate. Insert a blank row (`|`) between logical sections to create implicit grouping without breaking the table.
7. **Include source indicators** — Add superscript citations in table cells when data comes from specific sources: `~40%`¹, `$10/mo`². Define the citations in the Sources section below.

---

## Standard Research Output
Use this template for general research synthesis (not comparisons).

### Summary
[2-3 sentence overview of findings]

### Confidence: [High / Medium / Low]
- **High**: Multiple corroborating primary sources, clear consensus.
- **Medium**: Some gaps or single-source claims, but reasonable confidence.
- **Low**: Limited or conflicting information; explicitly note uncertainty.

### Key Findings
- [Finding 1] — [citation or source]
- [Finding 2] — [citation or source]
- [Finding 3] — [citation or source]

### Uncertainties / Gaps
- [What remains unclear or unverified]

### Recommended Next Steps
- [Actionable follow-up if needed]

---

## Sources and References

**Every research output MUST include a Sources section.** See `../search/SKILL.md` (Citation Requirements section) for the full citation rules, format, and template. This is the canonical source and applies to all research output.

For comparison tables, use superscript citations as described in the [Table-Writing Rules](#table-writing-rules) above.
