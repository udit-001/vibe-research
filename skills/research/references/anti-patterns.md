# Anti-Patterns and Troubleshooting

## Anti-Patterns

Things to actively avoid—each of these degrades research quality:

- **Confirmation bias**: Searching only for evidence that supports your hypothesis (e.g., *"library X problems"*, *"comparison critiques"*, *"why not Y"*).
- **First-plausible-research-fails**: The first result that sounds coherent is not the answer. Continue until you have corroboration from an independent source or explicitly note "single-source claim" in the output.
- **Information overload / analysis paralysis**: Opening 15+ tabs and synthesizing nothing. Cap fetches at 2–4 highest-signal sources per angle; spend the remaining budget on synthesis, not gathering.
- **Stale-source bias**: Querying only a 2023 blog post about a 2025 library. Always check publication/commit date; prefer the last 12–18 months for fast-moving topics.
- **Halo effect**: Reading what someone said about a repo instead of reading the repo itself. If a GitHub repo is in scope, inspect it before reading articles about it.
- **Hallucinated specifics**: Inventing function names, flags, version numbers, or quoted text that *"sounds right"* but isn't traceable to a cited URL or repo path. If you can't cite it, don't write it.
- **Burying uncertainty**: Writing confident prose over shaky evidence. Surface contested or low-evidence claims explicitly in Critical Analysis rather than hoping the user won't notice.
- **Skipping the deliverable shape**: Producing a wall of bullets when the user needed a comparison table, or a table when they needed a ranked recommendation. The deliverable is decided in step 1, not at the end.

---

## When Research Stalls

If the work feels like spinning rather than progressing, name the failure mode and apply the matching fix instead of just searching harder:

| Failure Mode | Fix |
|--------------|-----|
| **No vocabulary** — using key terms, getting only intro material | Run a terminology search (Deep Research Step 2) and read with expert terms. |
| **Single-perspective** — every source speaks with you | Run the counter-perspective pass (Deep Research Step 5). |
| **Domain blindness** — searching only one field | Search across different domains (e.g., databases vs. distributed systems, ML vs. statistics, frontend vs. graphical). |
| **Recency bias** — only modern sources, no historical context | Add *"2019"* or *"2023"* to queries. |
| **Breadth without depth** — many sources gathered, no synthesis | Stop gathering. Write what you know now; the gaps will reveal what is actually needed next. |
| **Compilation uncertainty** — unsure whether you are done? | Re-check scope (Step 1) and stopping signals (Step 6). If both say done, you're done; ship the synthesis. |
