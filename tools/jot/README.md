# Jot Setup Guide for Collaborative Planning

This guide documents how to set up [jot](https://github.com/badlogic/jot) — a minimal self-hosted collaborative markdown editor — for planning and feedback workflows between humans and agents.

## What You'll Get

- A self-hosted markdown editor running in Docker
- Inline comment threads anchored to specific text
- CLI access for reading, editing, and commenting on documents
- A workflow where reviewers add inline feedback and authors revise based on comments

---

## Prerequisites

- Node.js 18+ (for the jot CLI and PM2)
- PowerShell (required for PM2 commands)

### Installing Node.js and the jot CLI

jot's CLI (`@mariozechner/jot`) is a Node.js package. Install Node.js 18 or later via winget:

```powershell
winget install -e --id OpenJS.NodeJS.LTS
```

Close and reopen your terminal/PowerShell so the updated PATH takes effect, then install the jot CLI globally:

```powershell
npm install -g @mariozechner/jot
```

Verify the installation:

```powershell
node --version   # should be v18.x or later
jot --help       # should print CLI usage
```

---

## Step 1: Install PM2 and Create Data Directory

PM2 is a production-grade process manager for Node.js. It keeps jot running in the background, restarts it if it crashes, and can start it automatically on boot.

```powershell
# Install PM2 globally
npm install -g pm2

# Create a directory for jot data
mkdir C:\jot-data
```

---

## Step 2: Start Jot with PM2

```powershell
# Start jot as a background process
pm2 start "jot serve --port=3210 --data=C:\jot-data" --name jot

# Verify it's running
curl http://localhost:3210
# Should return HTML content
```

Jot will be available at **http://localhost:3210**

---

## Step 3: Configure PM2 for Startup

Save the PM2 configuration and enable automatic startup on boot:

```powershell
# Save the current process list
pm2 save

# Generate a startup script (run PowerShell as Administrator)
pm2 startup windows
# Follow the instructions it prints (usually involves running a command)
```

### PM2 Config File (Recommended)

Create `jot-pm2.json`:

```json
{
  "apps": [{
    "name": "jot",
    "script": "jot",
    "args": ["serve", "--port=3210", "--data=C:\\jot-data"],
    "instances": 1,
    "exec_mode": "fork",
    "env": {
      "NODE_ENV": "production"
    },
    "log_file": "C:\\jot-data\\logs\\combined.log",
    "out_file": "C:\\jot-data\\logs\\out.log",
    "error_file": "C:\\jot-data\\logs\\error.log",
    "autorestart": true,
    "max_restarts": 10,
    "min_uptime": "10s"
  }]
}
```

Then start with:

```powershell
pm2 start jot-pm2.json
pm2 save
pm2 startup
```

### PM2 Management Commands

```powershell
pm2 status jot        # Check if jot is running
pm2 logs jot          # View logs
pm2 restart jot       # Restart
pm2 stop jot          # Stop
pm2 delete jot        # Remove from PM2
```

---

## Step 4: Set Up Authentication

Jot uses a single owner password and API keys for programmatic access.

### 4.1 Set the Owner Password

Run this once to initialize the owner account:

```powershell
curl -s -X POST http://localhost:3210/api/auth/setup `
  -H "Content-Type: application/json" `
  -d '{"password":"12345678","confirmPassword":"12345678"}'
```

This returns a device token (temporary):

```json
{"ok":true,"token":"YOUR_DEVICE_TOKEN","ownerLocalStorageTokenKey":"md_owner_token"}
```

### 4.2 Create an API Key

Device tokens expire. For persistent CLI access, create a dedicated API key:

```powershell
# Exchange the device token for a session cookie
curl -s -c cookies.txt -X POST http://localhost:3210/api/auth/token `
  -H "Content-Type: application/json" `
  -d '{"token":"YOUR_DEVICE_TOKEN"}'

# Create an API key
curl -s -b cookies.txt -X POST http://localhost:3210/api/keys `
  -H "Content-Type: application/json" `
  -d '{}'
```

Returns:

```json
{"ok":true,"id":"...","label":"unnamed","key":"YOUR_API_KEY","createdAt":"..."}
```

**Save this API key.** It is used to register the CLI in the next step.

### 4.3 Register the CLI

Use the API key to register the jot instance:

```powershell
jot register local http://localhost:3210 YOUR_API_KEY
```

Test it:

```powershell
jot local list
```

> **Security note:** API keys can be revoked at any time from the jot web UI (Settings → API Keys) or via `DELETE /api/keys/:id`.

---

## Step 5: Create Your First Planning Document

```powershell
# Create a new note
jot local create "Sprint 1 Planning"

# Update with content
jot local update <note-id> markdown "# Sprint 1 Planning

## Goals
- [ ] Task one
- [ ] Task two

## Discussion
Use this section for feedback and questions.
"
```

Or create via the API:

```powershell
curl -s -b cookies.txt -X POST http://localhost:3210/api/notes `
  -H "Content-Type: application/json" `
  -d '{"title":"Sprint 1 Planning","markdown":"# Sprint 1 Planning\n\n## Goals\n- [ ] Task one\n- [ ] Task two\n\n## Discussion\nUse this section for feedback."}'
```

---

## Step 6: The Collaborative Workflow

The typical flow is: **Author creates a plan → Reviewer adds inline comments → Author revises based on feedback.**

This works for:
- Human author + human reviewer
- Human author + agent reviewer
- Agent author + human reviewer
- Any combination

### 6.1 Create a Share Link

Enable public access to a note so reviewers can view and comment without an account:

```powershell
# Update the note's share access
# Options: "none", "view", "comment", "edit"
jot local update <note-id> shareAccess comment
```

The share URL is: `http://localhost:3210/s/<share-id>`

### 6.2 Reviewer Adds Comments

**Via browser (no login required with share URL):**
1. Open the share URL
2. Select any text in the document
3. Add an inline comment

**Via CLI (if reviewer has an API key):**

```powershell
jot local comment <note-id> "exact quoted text" "Your feedback here"
```

### 6.3 Author Reads Comments

```powershell
# Read note with all comments
jot local read <note-id>
```

The output shows:
- Full markdown content
- Thread IDs and message IDs
- Author and timestamps

### 6.4 Author Responds and Revises

**Reply to a comment:**

```powershell
jot local reply <note-id> <thread-id> <message-id> "Your response here"
```

**Revise the document:**

```powershell
# Apply text edits (JSON array of {oldText, newText})
jot local edit <note-id> '[{"oldText":"Task one","newText":"Task one (updated)"}]'

# Or replace the entire markdown
jot local update <note-id> markdown "# Updated content..."
```

**Mark a thread as resolved when consensus is reached:**

```powershell
jot local resolve <note-id> <thread-id>
```

---

## Example: Complete Planning Session

**1. Author creates a plan:**

```powershell
jot local create "Database Migration RFC"
jot local update <id> markdown "# Database Migration RFC

## Current State
We use SQLite for article storage.

## Proposal
Migrate to PostgreSQL for better concurrency.

## Risks
- Data migration complexity
- Connection pooling setup
"
jot local update <id> shareAccess comment
```

**2. Reviewer opens the share URL and comments:**

> On: "Migrate to PostgreSQL for better concurrency."  
> Comment: "What about read replicas? We have heavy read load."

**3. Author reads and responds:**

```powershell
jot local read <id>
# Sees the comment on the PostgreSQL line
jot local reply <id> <thread-id> <msg-id> "Good point. I'll add a section on read replicas and connection pooling."
```

**4. Author updates the document:**

```powershell
jot local edit <id> '[{"oldText":"## Risks","newText":"## Read Replicas\nWe will configure 2 read replicas for the heavy aggregation queries.\n\n## Risks"}]'
```

**5. Reviewer resolves the thread when satisfied**

---

## Useful Commands

### Owner Mode (Registered with API Key)

| Command | Description |
|---------|-------------|
| `jot <alias> list` | List all notes |
| `jot <alias> search "query"` | Search notes by title and content |
| `jot <alias> read <id>` | Read note with comments |
| `jot <alias> create [title]` | Create a new note |
| `jot <alias> update <id> markdown "..."` | Replace full markdown content |
| `jot <alias> update <id> title "New title"` | Update note title |
| `jot <alias> update <id> shareAccess <level>` | Set sharing permissions (none/view/comment/edit) |
| `jot <alias> edit <id> '[{oldText, newText}]'` | Apply text edits |
| `jot <alias> comment <id> "quote" "body"` | Comment on quoted text |
| `jot <alias> reply <id> <tid> <mid> "body"` | Reply to a comment |
| `jot <alias> edit-comment <id> <mid> "new body"` | Edit an existing comment |
| `jot <alias> delete-comment <id> <mid>` | Delete a comment message |
| `jot <alias> resolve <id> <tid>` | Mark thread as resolved |
| `jot <alias> reopen <id> <tid>` | Reopen a resolved thread |
| `jot <alias> delete-thread <id> <tid>` | Delete entire comment thread |
| `jot <alias> delete <id>` | Delete a note |

### Shared Mode (Registered with Share URL)

Anyone with a share link can register and interact:

```powershell
jot register shared http://localhost:3210/s/<share-id>
jot shared read
jot shared edit '[{"oldText":"foo","newText":"bar"}]'
jot shared comment "quoted text" "comment body" --name="My Agent"
jot shared reply <thread-id> <message-id> "reply" --name="My Agent"
```

### Server Commands

| Command | Description |
|---------|-------------|
| `jot serve` | Start jot server (port 3210, data in ./data) |
| `jot serve --port=8080` | Start on custom port |
| `jot serve --data=C:\jot-data` | Use custom data directory |
| `pm2 status jot` | Check PM2 status |
| `pm2 logs jot` | View PM2 logs |
| `pm2 restart jot` | Restart jot via PM2 |
| `pm2 stop jot` | Stop jot via PM2 |

---

## Optional: Docker Deployment

If you prefer Docker over PM2, use this approach:

```powershell
# Clone the repository
git clone https://github.com/badlogic/jot.git C:\jot
cd C:\jot

# Create data directory
mkdir data/notes
```

Create `docker-compose.yml`:

```yaml
services:
  jot:
    image: node:18
    working_dir: /app
    command: npx @mariozechner/jot serve --port=3210 --data=/app/data
    volumes:
      - ./data:/app/data
    ports:
      - "3210:3210"
    restart: unless-stopped
```

Start the server:

```powershell
docker compose up -d
```
{
  "apps": [{
    "name": "jot",
    "script": "jot",
    "args": ["serve", "--port=3210", "--data=C:\\jot-data"],
    "instances": 1,
    "exec_mode": "fork",
    "env": {
      "NODE_ENV": "production"
    },
    "log_file": "C:\\jot-data\\logs\\combined.log",
    "out_file": "C:\\jot-data\\logs\\out.log",
    "error_file": "C:\\jot-data\\logs\\error.log",
    "autorestart": true,
    "max_restarts": 10,
    "min_uptime": "10s"
  }]
}
```

Then start with:

```powershell
pm2 start jot-pm2.json
pm2 save
pm2 startup
```

### Verify it's running

```powershell
# Check if jot is responding
curl http://localhost:3210

# Check the data directory
dir C:\jot-data\notes
```

> **Note:** After setting up, continue from [Step 4: Set Up Authentication](#step-4-set-up-authentication) to configure authentication and start collaborating.

---

## Data Persistence

All data is stored in `C:\jot-data`:

```
C:\jot-data\
  auth.json          # Owner password and tokens
  notes\
    <id>.md          # Markdown content
    <id>.json        # Metadata and comment threads
```

---

## API Endpoints

### Authentication
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/auth/setup` | POST | Set owner password on first run |
| `/api/auth/login` | POST | Authenticate with password |
| `/api/auth/token` | POST | Exchange device token for session cookie |
| `/api/auth/logout` | POST | Revoke device token |
| `/api/viewer` | GET | Get viewer authentication status |

### Note Management (Owner Only)
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/notes` | GET | List all notes (with optional search query) |
| `/api/notes` | POST | Create a new note |
| `/api/notes/:id` | GET | Get specific note |
| `/api/notes/:id` | PUT | Update note |
| `/api/notes/:id` | DELETE | Delete note |
| `/api/render` | POST | Render markdown to HTML |

### Shared Notes & Comments
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/share/:shareId` | GET | Get shared note |
| `/api/share/:shareId/identity` | POST | Set commenter name |
| `/api/share/:shareId/threads` | POST | Create comment thread |
| `/api/share/:shareId/threads/:threadId/replies` | POST | Reply to thread |
| `/api/share/:shareId/threads/:threadId` | PATCH | Update thread (resolve/reopen) |
| `/api/share/:shareId/threads/:threadId` | DELETE | Delete thread (owner only) |
| `/api/share/:shareId/messages/:messageId` | PATCH | Edit comment message |
| `/api/share/:shareId/messages/:messageId` | DELETE | Delete comment message |
| `/api/keys` | POST | Create API key |
| `/api/keys/:id` | DELETE | Revoke API key |

---

## Tips for Effective Collaboration

1. **Use descriptive titles** — Makes it easy to find plans via `jot local list`
2. **Comment on specific text** — Select exact quotes so the author knows precisely what to address
3. **Resolve threads** — Clear signal that consensus is reached
4. **Use checklists** — Great for tracking action items in sprint plans
5. **Set appropriate share access** — `view` for read-only, `comment` for feedback, `edit` for full collaboration
6. **Threaded replies** — Ask clarifying questions before making changes

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `401 Unauthorized` | API key is invalid or expired. Create a new one via the web UI (Settings → API Keys) |
| `Error 400: oldText is empty` | The `edit` command requires non-empty `oldText`. Use `update` to replace full markdown instead |
| Port 3210 in use | Check if another process is using port 3210: `netstat -ano | findstr 3210` |
| PM2 process not found | Ensure PM2 is installed: `npm install -g pm2` |
| PM2 startup fails | Run PowerShell as Administrator for `pm2 startup windows` |
| Reviewer can't comment | Check that `shareAccess` is set to `comment` or `edit` on the note |
| CLI command not found | Ensure `@mariozechner/jot` is installed globally: `npm install -g @mariozechner/jot` |

---

## Data Schema

### Note Schema
```json
{
  "id": "string",
  "title": "string",
  "shareId": "string",
  "createdAt": "ISO-8601 timestamp",
  "updatedAt": "ISO-8601 timestamp",
  "threads": [CommentThread]
}
```

### CommentThread Schema
```json
{
  "id": "string",
  "resolved": boolean,
  "createdAt": "ISO-8601 timestamp",
  "updatedAt": "ISO-8601 timestamp",
  "anchor": CommentAnchor,
  "messages": [CommentMessage]
}
```

### CommentAnchor Schema
```json
{
  "quote": "string",
  "prefix": "string",
  "suffix": "string",
  "start": number,
  "end": number
}
```

### CommentMessage Schema
```json
{
  "id": "string",
  "parentId": "string | null",
  "authorId": "string",
  "authorName": "string",
  "body": "string",
  "createdAt": "ISO-8601 timestamp",
  "updatedAt": "ISO-8601 timestamp"
}
```

---

*This guide documents the jot collaborative planning workflow for Windows with PM2, supporting both human and agent collaboration.*