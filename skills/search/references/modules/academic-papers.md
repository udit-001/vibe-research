# Academic Papers Module

**Trigger:** Paper lookup, academic research, algorithm understanding, literature review

## Search Sources
- **Google Scholar** — comprehensive academic search
- **arXiv** — preprints in physics, math, CS, and related fields
- **Hugging Face Papers** — trending ML/AI papers with community upvotes
- **Semantic Scholar** — AI-powered academic search
- **ACM Digital Library** — CS and engineering papers
- **IEEE Xplore** — engineering and technology papers
- **bioRxiv** — biology and life sciences preprints
- **ResearchGate** — academic social network with papers

## Query Strategies

1. **By topic with category filter**
   ```
   web_search_exa { "query": "category:research paper sparse attention mechanisms transformers", "numResults": 12 }
   ```

2. **Survey/review papers** (find these first for new domains)
   ```
   web_search_exa { "query": "category:research paper [topic] comprehensive survey review", "numResults": 10 }
   ```

3. **By author**
   ```
   web_search_exa { "query": "category:research paper [author name] [topic]", "numResults": 5 }
   ```

4. **By recency**
   ```
   web_search_exa { "query": "category:research paper [topic] advances 2025 2026", "numResults": 15 }
   ```

5. **Seminal works** (find via surveys first)
   ```
   web_search_exa { "query": "category:research paper [topic] foundational seminal citation", "numResults": 10 }
   ```

## Information Extraction

For each paper, extract:
- **Title, authors, year** — Basic bibliographic info
- **Abstract summary** — 2-3 sentence summary
- **Key contributions** — What the paper proposes/achieves
- **Methodology** — Approach used
- **Results** — Key findings with metrics
- **Citations** — Citation count if available
- **Availability** — Open access or paywalled

## Source Quality

- **Highest**: Peer-reviewed journal, high citation count
- **High**: Top conference (NeurIPS, ICML, ICLR, CVPR)
- **Medium**: Workshop paper, preprint with community validation
- **Low**: Unpublished preprint, no citations

## Citation Format

```
[Authors, "Title"](URL) — [Year] — [Venue] — [Key contribution]
```

Example:
```
[Vaswani et al., "Attention Is All You Need"](https://arxiv.org/abs/1706.03762) — 2017 — NeurIPS — Introduced transformer architecture
[Google Research, "BERT: Pre-training of Deep Bidirectional Transformers"](https://arxiv.org/abs/1810.04805) — 2019 — NAACL — Bidirectional language representation
```

## Finding Seminal Papers

1. Search for survey papers on the topic first
2. Read surveys to extract foundational references
3. Search for those specific papers
4. Check citation networks to identify key works

## Access Notes

- arXiv: Always open access
- Google Scholar: Often links to PDFs
- Semantic Scholar: Good for finding open-access versions
- ACM/IEEE: Usually paywalled, check for preprints
