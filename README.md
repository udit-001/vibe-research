# Vibe Research

AI-assisted deep research workspace for [OpenCode](https://opencode.ai) — multi-session tracking, Exa-powered web search, collaborative planning, and structured investigation workflows.

## Quick Start (Windows)

```batch
curl -fsSL https://raw.githubusercontent.com/udit-001/vibe-research/main/tools/setup-opencode/setup.bat -o %TEMP%\setup.bat && %TEMP%\setup.bat
```

```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/udit-001/vibe-research/main/tools/setup-opencode/setup.bat" -OutFile "$env:TEMP\setup.bat"; & "$env:TEMP\setup.bat"
```

Script installs: Windows Terminal, Git Bash, Node.js, OpenCode + DCP plugin, Exa MCP, PM2 + Jot CLI, skills, themes. Resumes after restart — re-run the same command.

## Skills

| Skill | Files |
|-------|-------|
| **Research** — planning, batch investigation, session management | [`SKILL.md`](skills/research/SKILL.md) · [`session-registry.md`](skills/research/references/session-registry.md) · [`batch-processing.md`](skills/research/references/batch-processing.md) · [`structured-output.md`](skills/research/references/structured-output.md) · [`research_session.py`](skills/research/tools/research_session.py) |
| **Search** — Exa-powered, domain-specific patterns | [`SKILL.md`](skills/search/SKILL.md) · [`patterns.md`](skills/search/references/patterns.md) · [`searching.md`](skills/search/references/searching.md) · [`source-quality.md`](skills/search/references/source-quality.md) · [`synthesis.md`](skills/search/references/synthesis.md) |
| **Jot Collaboration** — planning with inline comments | [`SKILL.md`](skills/jot-collaboration/SKILL.md) · [`research-planning.md`](skills/jot-collaboration/references/research-planning.md) |

## Tools

- **Jot** — self-hosted markdown editor ([README](tools/jot/README.md), [setup](tools/jot/setup.sh), [API key](tools/jot/setup-api-key.sh))
- **Setup** — Windows bootstrap ([setup.bat](tools/setup-opencode/setup.bat))
