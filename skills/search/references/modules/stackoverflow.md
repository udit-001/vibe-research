# Stack Overflow Module

**Trigger:** Programming questions, code implementation, API usage, debugging

## Search Sources
- **Stack Overflow** — primary technical Q&A
- **Stack Exchange** — specialized sites (Server Fault, Super User, etc.)
- **Technical forums** — language/framework-specific forums

## Query Strategies

1. **Exact error messages**
   ```
   web_search_exa { "query": "\"TypeError: Cannot read property of undefined\" javascript stackoverflow", "numResults": 10 }
   ```

2. **API usage examples**
   ```
   web_search_exa { "query": "[library] [function] usage example stackoverflow", "numResults": 10 }
   ```

3. **Best practices**
   ```
   web_search_exa { "query": "[language] [pattern] best practice stackoverflow accepted answer", "numResults": 10 }
   ```

4. **Common pitfalls**
   ```
   web_search_exa { "query": "[language] common mistake [pattern] stackoverflow", "numResults": 10 }
   ```

5. **Performance questions**
   ```
   web_search_exa { "query": "[language] performance optimization [operation] stackoverflow", "numResults": 10 }
   ```

## Information Extraction

For each answer, extract:
- **Question** — What was being asked
- **Accepted answer** — Officially accepted solution
- **Top-voted answer** — Highest community score (may differ from accepted)
- **Code examples** — Working code snippets
- **Explanation** — Why the solution works
- **Caveats** — Edge cases or limitations mentioned
- **Date** — When answered (check for outdated solutions)

## Source Quality

- **Highest**: Accepted answer with 100+ votes, official maintainer response
- **High**: Accepted answer, well-explained with code
- **Medium**: High-voted answer (not accepted), good explanation
- **Low**: Low-voted answer, untested code, outdated solution

## Citation Format

```
[Stack Overflow, "Question Title"](URL) — [Score: X] — [Accepted: yes/no] — [What we learned]
```

Example:
```
[Stack Overflow, "How to handle async/await in React useEffect"](https://stackoverflow.com/...) — Score: 245 — Accepted — Use IIFE pattern
[Stack Overflow, "Python list comprehension vs map performance"](https://stackoverflow.com/...) — Score: 89 — Not accepted — List comp faster for simple ops
```

## Important Notes

- **Check dates** — Old answers may be outdated
- **Read comments** — Often contain corrections or updates
- **Compare answers** — Accepted isn't always best
- **Look for "Edit" sections** — Authors often update answers
- **Check version tags** — Ensure answer matches your version
