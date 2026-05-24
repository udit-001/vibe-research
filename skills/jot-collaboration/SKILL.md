---
name: jot-collaboration
description: Collaborative brainstorming and planning using jot markdown editor with inline comments
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: collaborative-planning
---

## What I do

I facilitate collaborative brainstorming and planning workflows using jot, a self-hosted markdown editor with inline commenting capabilities. I help create, read, edit, and manage planning documents while enabling structured feedback through threaded discussions.

## Key Capabilities

- **Document Creation**: Create structured planning documents with markdown formatting
- **Inline Feedback**: Add context-specific comments on exact text segments for targeted feedback
- **Thread Management**: Track, respond to, and resolve discussion threads on specific content
- **Document Evolution**: Apply targeted text edits and update entire documents based on feedback
- **Collaboration Modes**: Work with both registered API keys and shared URLs for flexible access

## When to Use Me

Use this skill when you need to:
- Create brainstorming documents or RFCs (Requests for Comments)
- Gather structured feedback on planning documents
- Facilitate collaborative planning sessions between humans and agents
- Track discussion and consensus on specific text segments
- Enable iterative document refinement through inline comments

### Research Planning Mode

When loaded by the **research skill** (`skill:research`), this skill enters research planning mode. In this mode:

- Documents follow the **Research Plan template** (see `reference/research-planning.md`)
- Comments are expected on **scope options**, **clarifying questions**, and **stakes assessment**
- Thread resolution signals **consensus to proceed** with research execution
- The research skill will **extract the final brief** and delegate to search skill once planning is complete

For research-specific workflows, see `reference/research-planning.md`.

## Prerequisites

- jot CLI installed: `npm install -g @mariozechner/jot`
- jot server running (typically on localhost:3210)
- API key or share URL for document access
- Valid jot registration: `jot register <alias> <url> <api-key>`

## Core Workflows

### 1. Initial Planning Document

Create and share a planning document for collaborative feedback:

```
jot local create "Project Planning: <topic>"
jot local update <id> markdown "# Planning Document

## Objectives
- Clear goal statements
- Success criteria

## Approach
- Proposed methodology
- Technical considerations

## Discussion
- Open questions
- Concerns to address
"
jot local update <id> shareAccess comment
```

**Auto-open in browser** (when in research planning mode):
```bash
# Windows
start http://localhost:3210/n/<id>
# macOS
open http://localhost:3210/n/<id>
# Linux
xdg-open http://localhost:3210/n/<id>
```

### 2. Adding Contextual Feedback

Add inline comments on specific text for precise feedback:

```
jot local comment <id> "exact quoted text" "Your feedback or question here"
```

### 3. Reading and Responding

Review comments and provide structured responses:

```
jot local read <id>
jot local reply <id> <thread-id> <message-id> "Response addressing the feedback"
```

### 4. Iterative Refinement

Apply targeted edits based on discussion:

```
jot local edit <id> '[{"oldText":"original text","newText":"improved text"}]'
```

### 5. Consensus Tracking

Resolve threads when feedback is addressed:

```
jot local resolve <id> <thread-id>
```

## Common Patterns

### RFC (Request for Comments) Flow

1. Create comprehensive RFC document
2. Set share access to `comment` level
3. Share URL with stakeholders
4. Monitor and respond to inline feedback
5. Update document based on discussion
6. Resolve threads as consensus is reached

### Brainstorming Session

1. Create initial brainstorming document
2. Add structured sections for different aspects
3. Use inline comments for specific suggestions
4. Track multiple discussion threads
5. Consolidate feedback into refined approach

### Technical Review

1. Document technical decisions and rationale
2. Request feedback on specific technical approaches
3. Address concerns with inline replies
4. Update sections based on expert feedback
5. Mark threads resolved when validated

## Best Practices

- **Be Specific**: Quote exact text when adding comments for precise context
- **Thread Management**: Keep discussions focused and resolve threads when consensus is reached
- **Structured Documents**: Use clear markdown structure with sections and subsections
- **Share Wisely**: Set appropriate share access (`view`, `comment`, or `edit`) based on collaboration needs
- **Response Quality**: Provide thorough, well-reasoned responses to feedback
- **Version Control**: Use targeted edits (`jot local edit`) for small changes, full updates (`jot local update`) for major revisions

## Available Commands

### Document Management
- `jot local list` - List all available documents
- `jot local create "<title>"` - Create new document
- `jot local read <id>` - Read document with all comments and threads
- `jot local search "<query>"` - Search documents by content

### Content Editing
- `jot local update <id> markdown "<content>"` - Replace full markdown content
- `jot local update <id> title "<new-title>"` - Update document title
- `jot local update <id> shareAccess <level>` - Set sharing permissions
- `jot local edit <id> '[{oldText, newText}]'` - Apply targeted text edits

### Comment and Discussion
- `jot local comment <id> "quote" "body"` - Add inline comment on quoted text
- `jot local reply <id> <tid> <mid> "body"` - Reply to specific comment
- `jot local edit-comment <id> <mid> "new body"` - Edit existing comment
- `jot local delete-comment <id> <mid>` - Delete comment message

### Thread Management
- `jot local resolve <id> <tid>` - Mark discussion thread as resolved
- `jot local reopen <id> <tid>` - Reopen resolved discussion
- `jot local delete-thread <id> <tid>` - Delete entire discussion thread

## Integration Notes

This skill works best when:
- jot server is accessible (localhost:3210 by default)
- You have API key access or share URLs
- Documents are properly shared with appropriate permissions
- Feedback is structured around specific text segments

### Research Skill Integration

When invoked by the research skill, see `reference/research-planning.md` for:
- Research plan document templates
- How to interpret comments as research feedback
- Consensus detection rules
- Brief extraction for search delegation

## Troubleshooting

- **401 Unauthorized**: API key may be invalid - create new key via web UI
- **Share access denied**: Check `shareAccess` level is set appropriately
- **Edit command fails**: Ensure `oldText` exactly matches existing content
- **Comments not visible**: Verify document is being read with `jot local read` to include all threads