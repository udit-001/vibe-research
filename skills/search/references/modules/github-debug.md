# GitHub Debug Module

**Trigger:** Project bugs, error debugging, issue lookup, version-specific problems

## Search Sources
- **GitHub Issues** (open and closed) — excellent for known bugs and workarounds
- **GitHub Pull Requests** — for patches and fixes
- **GitHub Discussions** — for community workarounds

## Query Strategies

1. **Exact error messages** — Search for error text in quotes
   ```
   web_search_exa { "query": "\"RuntimeError: CUDA out of memory\" vllm github issue", "numResults": 10 }
   ```

2. **Issue templates** — Look for patterns matching the problem
   ```
   web_search_exa { "query": "github issue template bug report [library] [version]", "numResults": 5 }
   ```

3. **Workarounds** — Find solutions, not just explanations
   ```
   web_search_exa { "query": "[library] [error] workaround fix solution github", "numResults": 10 }
   ```

4. **Version-specific** — Check if issue is tied to specific versions
   ```
   web_search_exa { "query": "[library] version [X.Y.Z] bug regression github issue", "numResults": 10 }
   ```

5. **Closed issues** — Check for resolution patterns
   ```
   web_search_exa { "query": "[library] [error] closed issue fixed resolved", "numResults": 10 }
   ```

## Information Extraction

For each relevant issue, extract:
- **Issue number and status** (open/closed)
- **Error description** — Exact error message or stack trace
- **Workarounds** — Temporary fixes from comments
- **Resolution** — Official fix or PR that resolved it
- **Affected versions** — Which versions have this issue
- **Timeline** — When reported, when fixed

## Source Quality

- **Highest**: Official maintainer response, merged PR fixing the issue
- **High**: Community-verified workaround with multiple confirmations
- **Medium**: Single workaround, unverified
- **Low**: "Me too" comments without solutions

## Citation Format

```
[GitHub, org/repo#123, "Issue Title"](URL) — [Status: open/closed] — [What we learned]
```

Example:
```
[GitHub, vllm-project/vllm#4567, "CUDA OOM with large batch sizes"](https://github.com/...) — Closed — Fixed in v0.3.2 via PR #4600
```
