# GitHub-Specific Research Reference

## When to Use This Reference

Consult this document when your research involves GitHub-hosted repositories, code-level investigation, or GitHub-specific debugging. For general web research, technology comparisons, or architectural decisions, the main skill is sufficient.

---

## GitHub Repository Analysis

### Deep Repository Inspection

When evaluating a GitHub-hosted library or project:

1. **Clone and inspect locally** (or use available code analysis tools):
   ```bash
   git clone --depth=100 https://github.com/owner/repo.git /tmp/repo-analysis
   cd /tmp/repo-analysis
   ```
   
   If commit history matters for maintenance analysis, use full clone or specify depth:
   ```bash
   git clone --depth=188 https://github.com/owner/repo.git /tmp/repo-analysis
   ```

2. **Read key files**:
   - `README.md` - Project overview, features, quick start
   - `package.json`, `Cargo.toml`, `go.mod`, etc. - Dependencies and metadata
   - `LICENSE` - License type and restrictions
   - `CHANGELOG.md` or releases - Version history and breaking changes
   - Examples directory - Usage patterns and capabilities
   - Tests directory - Coverage and quality signals

3. **Analyze code structure**:
   ```bash
   # Count lines of code by language
   find . -type f -name "*.ts" -o -name "*.js" | xargs wc -l
   
   # Check test coverage
   find . -path "*/test*" -o -path "*/__tests__*" | head -20
   
   # Review recent commits
   git log --oneline -20
   ```

4. **Check activity signals** (via GitHub API or web fetch):
   - Stars, forks, watchers
   - Open/closed issues ratio
   - Latest release date
   - Commit frequency (last 3-6 months)
   - Contributor count

### GitHub API Endpoints for Research

```
# Repository overview
GET https://api.github.com/repos/{owner}/{repo}

# Recent commits
GET https://api.github.com/repos/{owner}/{repo}/commits?since=2024-01-01

# Issues with specific labels
GET https://api.github.com/repos/{owner}/{repo}/issues?labels=bug&state=open

# Release information
GET https://api.github.com/repos/{owner}/{repo}/releases/latest

# Contributors
GET https://api.github.com/repos/{owner}/{repo}/contributors
```

### Maintenance Assessment

Evaluate repository health:

| Signal | Green Flag | Red Flag |
|--------|-----------|----------|
| Last commit | Within 3 months | Over 12 months |
| Issue response | Maintainers reply within days | Issues unanswered for months |
| Release cadence | Regular releases | No releases for 6+ months |
| Open/closed ratio | More closed than open | Mostly open, few closed |
| Contributors | Multiple active contributors | Single maintainer |
| Dependencies | Few, well-maintained deps | Many outdated dependencies |

---

## GitHub Issues Search

### Finding Related Issues

**Search across all GitHub:**
```
"error message" site:github.com
```

**Scope to specific repository:**
```
"error message" site:github.com/owner/repo
```

**Search with GitHub qualifiers:**
- `is:issue` - Only issues (not PRs)
- `is:open` or `is:closed` - Filter by status
- `label:bug` - Filter by label
- `created:>2024-01-01` - Filter by date
- `comments:>5` - Issues with discussion

**Example searches:**
```
"TypeError: Cannot read property" site:github.com is:issue is:open
"react hooks memory leak" site:github.com/facebook/react is:issue
```

### Analyzing Issue Threads

When you find a relevant issue:

1. **Read the original report** - Understand the problem and reproduction steps
2. **Check for maintainer responses** - Are they engaged?
3. **Look for workarounds** - Often posted in comments
4. **Check linked PRs** - Is a fix in progress?
5. **Note resolution status** - Closed with fix? Still open? Won't fix?

---

## GitHub-Specific Debugging

### Error Message Research

1. **Search exact error**:
   ```
   "Uncaught TypeError: undefined is not a function" site:github.com
   ```

2. **Search with library name**:
   ```
   "undefined is not a function" site:github.com/facebook/react
   ```

3. **Search Stack Overflow**:
   ```
   "undefined is not a function" site:stackoverflow.com
   ```

4. **Fetch top results** for discussion details and resolution

### Pull Request Research

When investigating a feature or fix:

1. Search PRs with relevant keywords
2. Check merged vs open status
3. Review discussion and review comments
4. Look for linked issues

---

## GitHub Actions & CI Research

When evaluating CI/CD practices:

1. Check `.github/workflows/` directory
2. Review workflow files for:
   - Test coverage
   - Linting rules
   - Deployment processes
   - Security scanning
3. Check recent workflow runs for success rates

---

## Advanced GitHub Research

### Commit History Analysis

```bash
# Commit frequency by month
git log --format="%h %ad %s" --date=short | awk '{print $2}' | cut -d'-' -f1,2 | sort | uniq -c

# Top contributors
git shortlog -sn --no-merges

# Files changed most often
git log --pretty=format: --name-only | sort | uniq -c | sort -rg | head -20
```

### Release Analysis

1. Check release notes for breaking changes
2. Compare version tags to see changes
3. Review migration guides

```bash
# Compare two versions
git log v1.0.0..v2.0.0 --oneline

# Files changed between versions
git diff --stat v1.0.0 v2.0.0
```

---

## GitHub Research Best Practices

1. **Primary sources first**: Read the actual repo before reading blog posts about it
2. **Check multiple versions**: Look at both latest release and main branch
3. **Read tests**: Tests reveal intended behavior and edge cases
4. **Check issues before adopting**: Known bugs may be dealbreakers
5. **Evaluate maintainer responsiveness**: Unresponsive maintainers = risk
6. **Look for alternatives in issues**: Users often suggest alternatives in comments

---

*This reference covers GitHub-specific research workflows. For general research methodology, see the main Deep Research skill.*