# General Web Module

**Trigger:** General information, best practices, product comparisons, industry trends

## Search Sources
- **Reddit** (r/programming, r/webdev, r/javascript, topic-specific subreddits) — real-world experiences
- **Official documentation** and changelogs — authoritative information
- **Blog posts** and tutorials — detailed explanations
- **Hacker News** discussions — high-quality technical discourse
- **Dev.to** — developer community articles
- **Medium** — technical blog platform
- **Discord** — official channels for open source projects
- **X/Twitter** — technical announcements from developers

## Query Strategies

1. **Official recommendations first**
   ```
   web_search_exa { "query": "[technology] official documentation best practices 2025", "numResults": 10 }
   ```

2. **Community consensus**
   ```
   web_search_exa { "query": "reddit [technology] vs [alternative] experience production", "numResults": 10 }
   ```

3. **Real-world examples**
   ```
   web_search_exa { "query": "[technology] case study production usage scale", "numResults": 10 }
   ```

4. **Anti-patterns and pitfalls**
   ```
   web_search_exa { "query": "[technology] common mistakes anti-patterns avoid", "numResults": 10 }
   ```

5. **Performance benchmarks**
   ```
   web_search_exa { "query": "[technology] benchmark performance comparison 2025", "numResults": 10 }
   ```

6. **Trade-offs and decision factors**
   ```
   web_search_exa { "query": "when to use [technology] vs [alternative] decision factors", "numResults": 10 }
   ```

## Information Extraction

For each source, extract:
- **Key claims** — Main points made by the source
- **Evidence** — Data, benchmarks, examples supporting claims
- **Context** — Author expertise, date, bias
- **Caveats** — Limitations or conditions mentioned

## Source Quality

- **Highest**: Official documentation, maintainer blog posts
- **High**: Established tech blogs (Vercel, Netflix, Uber engineering blogs)
- **Medium**: Personal blogs with demonstrated expertise
- **Low**: Content farms, unverified claims

## Citation Format

```
[Author/Org, "Title"](URL) — [Date] — [Context: official docs / blog / community]
```

Example:
```
[Vercel, "Next.js 14 App Router Deep Dive"](https://nextjs.org/blog/...) — 2024-10 — Official documentation
[Reddit, r/webdev, "Next.js vs Remix in production"](https://reddit.com/...) — 2025-01 — Community experience
```
