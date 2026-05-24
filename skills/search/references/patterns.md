# Query Patterns by Domain

## Code and Documentation

Always include programming language and framework/library in your query.

```
// API usage
web_search_exa { "query": "Stripe API create subscription Node.js code example", "numResults": 5 }

// Error resolution
web_search_exa { "query": "React hydration mismatch server client explanation fix", "numResults": 10 }

// GitHub implementations
web_search_exa { "query": "GitHub repository [library] example project open source", "numResults": 10 }
```

Use `web_fetch_exa` to read official docs when you know the URL.

## Companies

Use `category:company` for structured company data (funding, headcount, description).

```
// By category
web_search_exa { "query": "category:company AI infrastructure startups San Francisco", "numResults": 10 }

// By stage
web_search_exa { "query": "category:company Series B fintech payments", "numResults": 10 }

// Similar to known company
web_search_exa { "query": "category:company companies like Stripe", "numResults": 8 }
```

For competitive intelligence, layer multiple angles:
```
web_search_exa { "query": "category:company companies like [target]", "numResults": 10 }
web_search_exa { "query": "category:company [category] software tools", "numResults": 15 }
web_search_exa { "query": "[category] startup launch funding announcement recently", "numResults": 15 }
```

For funding/investors:
```
web_search_exa { "query": "[company] funding round raised investors", "numResults": 5 }
web_search_exa { "query": "category:company [company]", "numResults": 5 }
```

## News and Recent Events

```
web_search_exa { "query": "category:news [topic] announcement", "numResults": 15 }
web_search_exa { "query": "[topic] news update latest development [month year]", "numResults": 15 }
```

For reactions/sentiment on recent events, search across platforms:
```
web_search_exa { "query": "[event] reaction analysis commentary", "numResults": 12 }
web_search_exa { "query": "[event] criticism concerns issues bugs", "numResults": 15 }
```

## Research Papers

Use `category:research paper` for Exa's paper index.

```
// By topic
web_search_exa { "query": "category:research paper sparse attention mechanisms for long context transformers", "numResults": 12 }

// Survey/review papers
web_search_exa { "query": "category:research paper [topic] comprehensive survey review", "numResults": 10 }

// By author
web_search_exa { "query": "category:research paper [author name] [topic]", "numResults": 5 }

// By recency (encode time in query)
web_search_exa { "query": "category:research paper large language model advances 2025 2026", "numResults": 15 }
```

To find seminal papers: search for survey papers first, then deep-read them to extract foundational references.

## People

Use `category:people` for LinkedIn-weighted results. For discovery queries, be specific -- vague queries like `"category:people researcher founder CEO startup"` will match many irrelevant LinkedIn profiles. Include specific companies, timeframes, or roles to narrow results.

```
// By company + role
web_search_exa { "query": "category:people engineer at OpenAI", "numResults": 10 }
web_search_exa { "query": "category:people VP director at Cursor", "numResults": 10 }

// By role + location
web_search_exa { "query": "category:people Head of Growth B2B SaaS startup San Francisco", "numResults": 12 }

// Specific person
web_search_exa { "query": "category:people Jane Smith Anthropic machine learning", "numResults": 5 }
```

For comprehensive company coverage, search by department and seniority in parallel:
```
web_search_exa { "query": "category:people engineering at Acme", "numResults": 10 }
web_search_exa { "query": "category:people product design at Acme", "numResults": 10 }
web_search_exa { "query": "category:people sales marketing at Acme", "numResults": 10 }
```

Supplement with non-LinkedIn sources:
```
web_search_exa { "query": "Acme team page employees about us", "numResults": 5 }
web_search_exa { "query": "joined Acme recently hired new role announcement", "numResults": 5 }
```

Deduplicate by LinkedIn URL (canonical) or name + current company (fallback).

## Hidden Relationships

Finding connections that aren't explicitly listed anywhere. Direct queries ("X clients") return articles about them, not actual connections. Use indirect signals instead.

**Start with the subject's own platforms:**
```
web_search_exa { "query": "[subject] official website blog podcast", "numResults": 5 }
web_search_exa { "query": "[subject] conversation interview testimonial guest", "numResults": 8 }
web_fetch_exa { "urls": ["https://subject-website.com/blog", "https://subject-website.com/about"] }
```

**For B2B (company -> customers):**
```
web_search_exa { "query": "[company] case study customer success story", "numResults": 5 }
web_fetch_exa { "urls": ["https://company.com/customers", "https://company.com/case-studies"] }
```

**Indirect signal searches:**
```
// Testimonials
web_search_exa { "query": "personal blog [subject] changed my life testimonial", "numResults": 15 }

// Duration markers (high confidence -- people don't fabricate decades)
web_search_exa { "query": "[subject] years decades longtime worked with known since", "numResults": 10 }

// Terminology detection: find insider terms, then search for people using them
web_search_exa { "query": "[subject] method terminology concepts framework", "numResults": 5 }
web_search_exa { "query": "[unique term 1] [unique term 2] personal story", "numResults": 10 }
```
