#!/usr/bin/env python3
# /// script
# requires-python = ">=3.10"
# dependencies = ["click>=8.0", "rich>=13.0", "pydantic>=2.0"]
# ///
# -*- coding: utf-8 -*-
"""
Research Session Manager CLI

Manages research sessions with unique IDs, tracks progress, and handles
session lifecycle: {', '.join(STATUSES)}.

Uses inline UV dependency declarations (PEP 723) - run with:
    uv run research_session.py <command>

Or install dependencies manually:
    pip install click rich pydantic

DATA STORE: JSON file only (no SQLite, no database, no migrations).
All session data is stored in a single JSON file for flexible nested structures.
"""

from __future__ import annotations

import json
import os
import subprocess
import sys
from datetime import datetime
from pathlib import Path
from typing import Any, Optional

from rich.console import Console
from rich.table import Table

import click

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

STATUSES = ["planning", "active", "paused", "completed", "cancelled", "failed"]


# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

DEFAULT_DATA_PATH = Path.cwd() / ".research" / "sessions.json"
JOT_REGISTRY_PATH = Path.cwd() / ".research" / "jot_registry.json"


def get_data_path() -> Path:
    """Get the data file path, respecting environment override."""
    env_path = os.environ.get("RESEARCH_SESSION_DATA")
    if env_path:
        return Path(env_path)
    return DEFAULT_DATA_PATH


def ensure_data_dir(data_path: Path) -> None:
    """Ensure the data directory exists."""
    data_path.parent.mkdir(parents=True, exist_ok=True)


# ---------------------------------------------------------------------------
# Data Model
# ---------------------------------------------------------------------------

class SessionStore:
    """JSON file-based store for research sessions with nested structures."""

    def __init__(self, data_path: Optional[Path] = None):
        self.data_path = data_path or get_data_path()
        ensure_data_dir(self.data_path)
        self._data = self._load()

    def _load(self) -> dict:
        """Load data from JSON file."""
        if self.data_path.exists():
            try:
                with open(self.data_path, "r", encoding="utf-8") as f:
                    return json.load(f)
            except (json.JSONDecodeError, IOError):
                pass
        return {"sessions": {}, "version": 1, "last_updated": ""}

    def _save(self) -> None:
        """Save data to JSON file."""
        self._data["last_updated"] = datetime.now().isoformat()
        with open(self.data_path, "w", encoding="utf-8") as f:
            json.dump(self._data, f, indent=2, ensure_ascii=False)

    def _generate_id(self) -> str:
        """Generate next session ID (R001, R002, ...)."""
        sessions = self._data.get("sessions", {})
        if not sessions:
            return "R001"
        max_num = max(int(sid[1:]) for sid in sessions.keys())
        return f"R{max_num + 1:03d}"

    def create_session(self, title: str, items_total: int = 0) -> dict:
        """Create a new research session."""
        now = datetime.now().isoformat()
        session_id = self._generate_id()

        session = {
            "id": session_id,
            "title": title,
            "status": "planning",
            "started_at": now,
            "completed_at": None,
            "items_total": items_total,
            "items_completed": 0,
            "last_activity_at": now,
            "documents": {},
            "reason": None,
            "created_at": now,
            "updated_at": now,
            # Nested structures for complex research
            "outline": [],
            "fields": {},
            "results": {},
            "batches": [],
            "notes": [],
        }

        self._data["sessions"][session_id] = session
        self._save()
        return session

    def get_session(self, session_id: str) -> Optional[dict]:
        """Get a session by ID."""
        return self._data.get("sessions", {}).get(session_id)

    def list_sessions(self, status: Optional[str] = None) -> list[dict]:
        """List sessions, optionally filtered by status."""
        sessions = self._data.get("sessions", {}).values()
        if status:
            sessions = [s for s in sessions if s["status"] == status]
        return sorted(sessions, key=lambda s: s["created_at"], reverse=True)

    def update_session(self, session_id: str, **kwargs) -> bool:
        """Update session fields."""
        session = self.get_session(session_id)
        if not session:
            return False

        for key, value in kwargs.items():
            if key in session:
                session[key] = value

        session["updated_at"] = datetime.now().isoformat()
        session["last_activity_at"] = datetime.now().isoformat()
        self._save()
        return True

    def update_status(self, session_id: str, new_status: str) -> bool:
        """Update session status."""
        updates = {"status": new_status}
        if new_status == "completed":
            updates["completed_at"] = datetime.now().isoformat()
        return self.update_session(session_id, **updates)

    def update_progress(self, session_id: str, items_completed: Optional[int] = None,
                       items_total: Optional[int] = None) -> bool:
        """Update session progress."""
        updates = {}
        if items_completed is not None:
            updates["items_completed"] = items_completed
        if items_total is not None:
            updates["items_total"] = items_total
        return self.update_session(session_id, **updates)

    def add_document(self, session_id: str, doc_name: str, doc_id: str) -> bool:
        """Add a document reference to a session."""
        session = self.get_session(session_id)
        if not session:
            return False
        session["documents"][doc_name] = doc_id
        return self.update_session(session_id)

    def add_outline_item(self, session_id: str, item: dict) -> bool:
        """Add an item to the research outline."""
        session = self.get_session(session_id)
        if not session:
            return False
        session["outline"].append(item)
        return self.update_session(session_id)

    def add_field(self, session_id: str, category: str, field: dict) -> bool:
        """Add a field definition to a session."""
        session = self.get_session(session_id)
        if not session:
            return False
        if category not in session["fields"]:
            session["fields"][category] = []
        session["fields"][category].append(field)
        return self.update_session(session_id)

    def add_result(self, session_id: str, item_name: str, result: dict) -> bool:
        """Add a research result for an item."""
        session = self.get_session(session_id)
        if not session:
            return False
        session["results"][item_name] = result
        session["items_completed"] = len(session["results"])
        return self.update_session(session_id)

    def add_batch(self, session_id: str, batch: dict) -> bool:
        """Add a batch record to a session."""
        session = self.get_session(session_id)
        if not session:
            return False
        session["batches"].append(batch)
        return self.update_session(session_id)

    def add_note(self, session_id: str, note: str) -> bool:
        """Add a note to a session."""
        session = self.get_session(session_id)
        if not session:
            return False
        session["notes"].append({
            "text": note,
            "timestamp": datetime.now().isoformat(),
        })
        return self.update_session(session_id)

    def delete_session(self, session_id: str) -> bool:
        """Delete a session."""
        if session_id in self._data.get("sessions", {}):
            del self._data["sessions"][session_id]
            self._save()
            return True
        return False

    def get_stats(self) -> dict:
        """Get aggregate statistics."""
        sessions = self._data.get("sessions", {}).values()
        stats = {}
        for s in sessions:
            status = s["status"]
            if status not in stats:
                stats[status] = {"count": 0, "total_items": 0, "completed_items": 0}
            stats[status]["count"] += 1
            stats[status]["total_items"] += s.get("items_total", 0)
            stats[status]["completed_items"] += s.get("items_completed", 0)
        return stats

    def export_session(self, session_id: str) -> Optional[dict]:
        """Export a session with all nested data."""
        session = self.get_session(session_id)
        if not session:
            return None
        return {
            "session": session,
            "export_time": datetime.now().isoformat(),
            "version": self._data.get("version", 1),
        }

    def import_session(self, data: dict) -> Optional[dict]:
        """Import a session from exported data."""
        session = data.get("session")
        if not session:
            return None
        # Generate new ID to avoid conflicts
        session["id"] = self._generate_id()
        session["created_at"] = datetime.now().isoformat()
        session["updated_at"] = datetime.now().isoformat()
        self._data["sessions"][session["id"]] = session
        self._save()
        return session


# ---------------------------------------------------------------------------
# Jot Integration
# ---------------------------------------------------------------------------

def run_jot(*args: str) -> str:
    """Run a jot CLI command and return stdout."""
    cmd = ["jot", "local", *args]
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        print(f"[ERROR] jot command failed: {' '.join(cmd)}")
        print(f"stderr: {e.stderr.strip()}")
        sys.exit(1)
    except FileNotFoundError:
        print("[ERROR] 'jot' CLI not found. Install: npm install -g @mariozechner/jot")
        sys.exit(1)


def _registry_file() -> Path:
    """Path to the cached Jot registry document ID."""
    path = JOT_REGISTRY_PATH
    path.parent.mkdir(parents=True, exist_ok=True)
    return path


def _load_registry_id() -> str | None:
    """Load cached registry document ID from local file."""
    path = _registry_file()
    if path.exists():
        try:
            data = json.loads(path.read_text())
            return data.get("registry_id")
        except (json.JSONDecodeError, OSError):
            return None
    return None


def _save_registry_id(registry_id: str) -> None:
    """Cache registry document ID to local file."""
    path = _registry_file()
    path.write_text(json.dumps({"registry_id": registry_id}, indent=2))


def sync_to_jot(store: SessionStore) -> str:
    """Sync all sessions to a Jot registry document for human-readable overview."""
    sessions = store.list_sessions()

    lines = ["# Research Session Registry", ""]

    # Active
    active = [s for s in sessions if s["status"] in ("planning", "active", "paused", "failed")]
    lines.append(f"## Active Sessions ({len(active)})")
    lines.append("")
    for s in active:
        remaining = s["items_total"] - s["items_completed"]
        pct = (s["items_completed"] / s["items_total"] * 100) if s["items_total"] > 0 else 0
        lines.append(f"### {s['id']} | {s['title']}")
        lines.append(f"- **Status:** {s['status']}")
        lines.append(f"- **Started:** {s['started_at']}")
        lines.append(f"- **Items:** {s['items_total']} total, {s['items_completed']} complete, {remaining} remaining ({pct:.0f}%)")
        lines.append(f"- **Last activity:** {s['last_activity_at']}")
        docs = s.get("documents", {})
        if docs:
            doc_links = ", ".join(f"[{name}]({id})" for name, id in docs.items())
            lines.append(f"- **Documents:** {doc_links}")
        # Show outline preview if available
        outline = s.get("outline", [])
        if outline:
            lines.append(f"- **Outline:** {len(outline)} items")
        lines.append("")

    # Completed
    completed = [s for s in sessions if s["status"] == "completed"]
    lines.append(f"## Completed Sessions ({len(completed)})")
    lines.append("")
    for s in completed:
        lines.append(f"### {s['id']} | {s['title']}")
        lines.append(f"- **Status:** completed")
        lines.append(f"- **Started:** {s['started_at']}")
        lines.append(f"- **Completed:** {s['completed_at']}")
        lines.append(f"- **Items:** {s['items_total']} total")
        lines.append("")

    # Cancelled
    cancelled = [s for s in sessions if s["status"] == "cancelled"]
    lines.append(f"## Cancelled Sessions ({len(cancelled)})")
    lines.append("")
    for s in cancelled:
        lines.append(f"### {s['id']} | {s['title']}")
        lines.append(f"- **Status:** cancelled")
        lines.append(f"- **Reason:** {s.get('reason', 'N/A')}")
        lines.append("")

    content = "\n".join(lines)

    # Try cached registry doc ID first
    registry_id = _load_registry_id()
    if registry_id:
        try:
            run_jot("update", registry_id, "markdown", content)
            return registry_id
        except SystemExit:
            pass  # cached ID is stale, fall through to find-or-create

    # Find or create registry document
    # `jot local` output is tab-separated: <id>\t<title>\t<timestamp>
    output = run_jot("list")
    registry_id = None
    for line in output.split("\n"):
        if "Research Session Registry" in line:
            parts = line.split("\t", 1)
            if len(parts) >= 1:
                registry_id = parts[0].strip()
                break

    if registry_id:
        run_jot("update", registry_id, "markdown", content)
    else:
        raw = run_jot("create", "Research Session Registry")
        registry_id = raw.split("\t", 1)[0].strip()
        run_jot("update", registry_id, "markdown", content)

    _save_registry_id(registry_id)
    return registry_id


# ---------------------------------------------------------------------------
# Output Helpers
# ---------------------------------------------------------------------------

def print_session_table(sessions: list[dict], title: str = "Sessions") -> None:
    """Print sessions in a table format."""
    console = Console()
    table = Table(title=title)
    table.add_column("ID", style="cyan", no_wrap=True)
    table.add_column("Title", style="green")
    table.add_column("Status", style="yellow")
    table.add_column("Progress", style="magenta")
    table.add_column("Last Activity", style="dim")

    for s in sessions:
        total = s.get("items_total", 0)
        completed = s.get("items_completed", 0)
        pct = (completed / total * 100) if total > 0 else 0
        progress = f"{completed}/{total} ({pct:.0f}%)"
        table.add_row(s["id"], s["title"], s["status"], progress, s.get("last_activity_at", ""))

    console.print(table)


def print_session_detail(session: dict) -> None:
    """Print detailed session information."""
    total = session.get("items_total", 0)
    completed = session.get("items_completed", 0)
    remaining = total - completed
    pct = (completed / total * 100) if total > 0 else 0

    console = Console()
    console.print(f"\n[bold cyan]{session['id']}[/bold cyan] | [bold]{session['title']}[/bold]")
    console.print(f"Status: [yellow]{session['status']}[/yellow]")
    console.print(f"Progress: [magenta]{completed}/{total}[/magenta] ({pct:.1f}%) - {remaining} remaining")
    console.print(f"Started: {session.get('started_at', 'N/A')}")
    if session.get('completed_at'):
        console.print(f"Completed: {session['completed_at']}")
    console.print(f"Last activity: {session.get('last_activity_at', 'N/A')}")

    docs = session.get("documents", {})
    if docs:
        console.print("\n[bold]Documents:[/bold]")
        for name, doc_id in docs.items():
            console.print(f"  {name}: {doc_id}")

    outline = session.get("outline", [])
    if outline:
        console.print(f"\n[bold]Outline:[/bold] {len(outline)} items")
        for item in outline[:5]:
            console.print(f"  - {item.get('name', 'Unnamed')}")
        if len(outline) > 5:
            console.print(f"  ... and {len(outline) - 5} more")

    fields = session.get("fields", {})
    if fields:
        console.print(f"\n[bold]Fields:[/bold] {sum(len(v) for v in fields.values())} total")
        for cat, field_list in fields.items():
            console.print(f"  {cat}: {len(field_list)} fields")

    results = session.get("results", {})
    if results:
        console.print(f"\n[bold]Results:[/bold] {len(results)} items researched")

    notes = session.get("notes", [])
    if notes:
        console.print(f"\n[bold]Notes:[/bold] {len(notes)} entries")

    if session.get("reason"):
        console.print(f"\n[dim]Reason: {session['reason']}[/dim]")


# ---------------------------------------------------------------------------
# CLI Commands (Click version)
# ---------------------------------------------------------------------------

@click.group()
@click.option("--data", "-d", type=click.Path(), help="Data file path override")
@click.pass_context
def cli(ctx, data):
    """Research Session Manager - Track and manage research projects."""
    if data:
        os.environ["RESEARCH_SESSION_DATA"] = data
    ctx.ensure_object(dict)
    ctx.obj["store"] = SessionStore()

@cli.command()
@click.argument("title")
@click.option("--items", "-i", type=int, default=0, help="Total number of items")
@click.option("--sync/--no-sync", default=True, help="Sync to Jot registry")
@click.pass_context
def create(ctx, title, items, sync):
    """Create a new research session."""
    store = ctx.obj["store"]
    session = store.create_session(title, items)

    print(f"Created session {session['id']} | {session['title']}")
    print(f"Status: {session['status']}")
    print(f"Items: {session['items_total']} total")
    print(f"Started: {session['started_at']}")
    print(f"\nNext steps:")
    print(f"  1. Create outline: research_session.py jot-create {session['id']} \"Outline\"")
    print(f"  2. Create fields:  research_session.py jot-create {session['id']} \"Fields\"")
    print(f"  3. Update status:  research_session.py status {session['id']} active")

    if sync:
        sync_to_jot(store)
        print(f"\nSynced to Jot registry.")

@cli.command("list")
@click.option("--status", "-s", type=click.Choice(STATUSES),
              help="Filter by status")
@click.pass_context
def list_sessions(ctx, status):
    """List research sessions."""
    store = ctx.obj["store"]
    sessions = store.list_sessions(status)

    if not sessions:
        if status:
            print(f"No sessions with status '{status}'.")
        else:
            print("No research sessions found.")
        return

    status_label = status.upper() if status else "ALL"
    print_session_table(sessions, f"{status_label} SESSIONS ({len(sessions)})")

@cli.command()
@click.argument("session_id")
@click.pass_context
def show(ctx, session_id):
    """Show session details."""
    store = ctx.obj["store"]
    session = store.get_session(session_id)
    if not session:
        click.echo(f"[ERROR] Session {session_id} not found.", err=True)
        sys.exit(1)
    print_session_detail(session)

@cli.command()
@click.argument("session_id")
@click.argument("new_status", type=click.Choice(STATUSES))
@click.option("--sync/--no-sync", default=True, help="Sync to Jot registry")
@click.pass_context
def status(ctx, session_id, new_status, sync):
    """Update session status."""
    store = ctx.obj["store"]
    if not store.get_session(session_id):
        click.echo(f"[ERROR] Session {session_id} not found.", err=True)
        sys.exit(1)

    store.update_status(session_id, new_status)
    print(f"Updated {session_id} status to: {new_status}")

    if sync:
        sync_to_jot(store)

@cli.command()
@click.argument("session_id")
@click.option("--completed", "-c", type=int, help="Items completed")
@click.option("--total", "-t", type=int, help="Total items")
@click.option("--sync/--no-sync", default=True, help="Sync to Jot registry")
@click.pass_context
def progress(ctx, session_id, completed, total, sync):
    """Update session progress."""
    store = ctx.obj["store"]
    if not store.get_session(session_id):
        click.echo(f"[ERROR] Session {session_id} not found.", err=True)
        sys.exit(1)

    store.update_progress(session_id, completed, total)
    session = store.get_session(session_id)
    total = session.get("items_total", 0)
    completed = session.get("items_completed", 0)
    pct = (completed / total * 100) if total > 0 else 0
    print(f"Updated {session_id} progress: {completed}/{total} ({pct:.1f}%)")

    if sync:
        sync_to_jot(store)

@cli.command()
@click.argument("session_id")
@click.argument("doc_name")
@click.argument("doc_id")
@click.option("--sync/--no-sync", default=True, help="Sync to Jot registry")
@click.pass_context
def doc(ctx, session_id, doc_name, doc_id, sync):
    """Add a document link to a session."""
    store = ctx.obj["store"]
    if not store.get_session(session_id):
        click.echo(f"[ERROR] Session {session_id} not found.", err=True)
        sys.exit(1)

    store.add_document(session_id, doc_name, doc_id)
    print(f"Added document '{doc_name}' ({doc_id}) to {session_id}")

    if sync:
        sync_to_jot(store)

@cli.command("jot-create")
@click.argument("session_id")
@click.argument("doc_name")
@click.option("--sync/--no-sync", default=True, help="Sync to Jot registry")
@click.pass_context
def jot_create(ctx, session_id, doc_name, sync):
    """Create a Jot document and link it to a session.

    Creates a document in Jot titled 'RNNN | <doc_name>: <session title>'
    and stores the returned document ID in the session's documents dict.
    """
    store = ctx.obj["store"]
    session = store.get_session(session_id)
    if not session:
        click.echo(f"[ERROR] Session {session_id} not found.", err=True)
        sys.exit(1)

    title = f"{session_id} | {doc_name}: {session['title']}"
    raw = run_jot("create", title)
    doc_id = raw.split("\t", 1)[0].strip()
    store.add_document(session_id, doc_name, doc_id)
    print(f"Created Jot doc '{title}' ({doc_id}) and linked to {session_id}")

    if sync:
        sync_to_jot(store)

@cli.command()
@click.argument("session_id")
@click.option("--reason", "-r", default="User cancelled", help="Cancellation reason")
@click.option("--sync/--no-sync", default=True, help="Sync to Jot registry")
@click.pass_context
def cancel(ctx, session_id, reason, sync):
    """Cancel a session."""
    store = ctx.obj["store"]
    session = store.get_session(session_id)
    if not session:
        click.echo(f"[ERROR] Session {session_id} not found.", err=True)
        sys.exit(1)

    store.update_status(session_id, "cancelled")
    store.update_session(session_id, reason=reason)
    print(f"Cancelled {session_id} | {session['title']}")
    print(f"Reason: {reason}")

    if sync:
        sync_to_jot(store)

@cli.command()
@click.pass_context
def stats(ctx):
    """Show aggregate statistics."""
    store = ctx.obj["store"]
    stats = store.get_stats()

    console = Console()
    table = Table(title="Research Session Statistics")
    table.add_column("Status", style="cyan")
    table.add_column("Count", style="green", justify="right")
    table.add_column("Total Items", style="magenta", justify="right")
    table.add_column("Completed", style="yellow", justify="right")

    for status, data in sorted(stats.items()):
        table.add_row(
            status,
            str(data["count"]),
            str(data["total_items"]),
            str(data["completed_items"]),
        )
    console.print(table)

@cli.command()
@click.argument("session_id")
@click.pass_context
def resume(ctx, session_id):
    """Show resume information for a session."""
    store = ctx.obj["store"]
    session = store.get_session(session_id)
    if not session:
        click.echo(f"[ERROR] Session {session_id} not found.", err=True)
        sys.exit(1)

    total = session.get("items_total", 0)
    completed = session.get("items_completed", 0)
    remaining = total - completed

    print(f"\n{'='*60}")
    print(f"RESUME: {session['id']} | {session['title']}")
    print(f"{'='*60}")
    print(f"Status: {session['status']}")
    print(f"Progress: {completed}/{total} complete, {remaining} remaining")

    if remaining > 0:
        print(f"\nNext item to research: item {completed + 1}")
        print(f"\nTo continue research:")
        print(f"  1. Update status: uv run research_session.py status {session_id} active")
        print(f"  2. Continue with item {completed + 1}")
    else:
        print(f"\nAll items complete! Mark as completed:")
        print(f"  uv run research_session.py status {session_id} completed")

    docs = session.get("documents", {})
    if docs:
        print(f"\nSession documents:")
        for name, doc_id in docs.items():
            print(f"  {name}: {doc_id}")

    outline = session.get("outline", [])
    if outline:
        print(f"\nOutline ({len(outline)} items):")
        for i, item in enumerate(outline[:10], 1):
            print(f"  {i}. {item.get('name', 'Unnamed')}")
        if len(outline) > 10:
            print(f"  ... and {len(outline) - 10} more")

@cli.command()
@click.argument("session_id")
@click.option("--force", "-f", is_flag=True, help="Skip confirmation")
@click.option("--sync/--no-sync", default=True, help="Sync to Jot registry")
@click.pass_context
def delete(ctx, session_id, force, sync):
    """Delete a session."""
    store = ctx.obj["store"]
    session = store.get_session(session_id)
    if not session:
        click.echo(f"[ERROR] Session {session_id} not found.", err=True)
        sys.exit(1)

    if not force:
        confirm = input(f"Delete session {session_id} | {session['title']}? [y/N]: ")
        if confirm.lower() != "y":
            print("Cancelled.")
            return

    store.delete_session(session_id)
    print(f"Deleted {session_id} | {session['title']}")

    if sync:
        sync_to_jot(store)

@cli.command()
@click.pass_context
def sync(ctx):
    """Sync all sessions to Jot registry."""
    store = ctx.obj["store"]
    registry_id = sync_to_jot(store)
    print(f"Synced to Jot registry: {registry_id}")

@cli.command()
@click.pass_context
def next_id(ctx):
    """Get the next available session ID."""
    store = ctx.obj["store"]
    sessions = store.list_sessions()
    if sessions:
        max_num = max(int(s["id"][1:]) for s in sessions)
        print(f"R{max_num + 1:03d}")
    else:
        print("R001")

@cli.command()
@click.argument("session_id")
@click.argument("json_data")
@click.pass_context
def add_outline(ctx, session_id, json_data):
    """Add outline items from JSON."""
    store = ctx.obj["store"]
    if not store.get_session(session_id):
        click.echo(f"[ERROR] Session {session_id} not found.", err=True)
        sys.exit(1)

    try:
        items = json.loads(json_data)
        if type(items) is not list:
            items = [items]
        for item in items:
            store.add_outline_item(session_id, item)
        print(f"Added {len(items)} outline items to {session_id}")
    except json.JSONDecodeError:
        click.echo("[ERROR] Invalid JSON data", err=True)
        sys.exit(1)

@cli.command()
@click.argument("session_id")
@click.pass_context
def export(ctx, session_id):
    """Export a session to JSON."""
    store = ctx.obj["store"]
    data = store.export_session(session_id)
    if not data:
        click.echo(f"[ERROR] Session {session_id} not found.", err=True)
        sys.exit(1)
        print(json.dumps(data, indent=2))


def main():
    cli()


if __name__ == "__main__":
    main()
