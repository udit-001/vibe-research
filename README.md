# Vibe Research

One-command setup for [OpenCode](https://opencode.ai) on Windows — an AI agent for deep research with web search, collaborative planning, and structured investigation workflows.

## Quick Start (Windows)

**Option 1 — Command Prompt (uses built-in `curl`):**

```batch
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/vibe-research/main/tools/setup-opencode/setup.bat -o %TEMP%\setup.bat && %TEMP%\setup.bat
```

**Option 2 — PowerShell (native, no curl needed):**

```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/YOUR_USERNAME/vibe-research/main/tools/setup-opencode/setup.bat" -OutFile "$env:TEMP\setup.bat"; & "$env:TEMP\setup.bat"
```

> **Resuming after restart:** The script saves its progress. If it asks you to restart, just **run the same one-liner again** after reopening your terminal — it will pick up where it left off.

This single command downloads and runs the setup script which will:

1. Install Windows Terminal
2. Install Git + configure Git Bash
3. Install Node.js
4. Install OpenCode + DCP plugin
5. Configure Exa MCP (web search)
6. Install PM2 + Jot CLI
7. Copy research skills to OpenCode
8. Set up themes and aliases

The script may ask you to **restart your terminal** 1-2 times (after installing Git or Node). Just run the same one-liner again — it automatically resumes where it left off.

**When complete, open Windows Terminal** (now installed) and run:
```bash
opencode --help
```

---

## What's Inside

After setup, you'll have an AI research workspace with:

- **Deep Research** — Interactive planning framework that clarifies objectives before investigating
- **Web Search** — Exa-powered search with domain-specific patterns (companies, papers, people, code)
- **Collaborative Planning** — Jot markdown editor with inline comments for human/agent collaboration
- **Windows Terminal** — Pre-configured with Git Bash, dark theme, and `oc` alias

## Project Structure

```
vibe-research/
├── config/
│   └── opencode.json         # OpenCode configuration
├── skills/                   # Agent skills (auto-loaded by OpenCode)
│   ├── research/             # Deep research planning framework
│   ├── search/               # Exa web search orchestrator
│   └── jot-collaboration/    # Collaborative planning with Jot
└── tools/
    ├── jot/                  # Jot editor setup scripts
    └── setup-opencode/       # Windows bootstrap (the setup.bat above)
```

## Skills

### Research (`skills/research/`)
Interactive research planning framework that teaches agents to clarify objectives through iterative questioning before conducting investigation.

### Search (`skills/search/`)
Deep research powered by Exa. Use for lead generation, literature reviews, competitive analysis, or any query where one search falls short.

### Jot Collaboration (`skills/jot-collaboration/`)
Collaborative brainstorming and planning using the Jot markdown editor with inline comments and threaded discussions.

## Tools

### Jot (`tools/jot/`)
A minimal self-hosted collaborative markdown editor for planning and feedback workflows between humans and agents.

**Quick start after setup:**
```bash
# Start the Jot server
pm2 start ~/jot-pm2.json

# See full guide
cat tools/jot/README.md
```

## License

MIT
