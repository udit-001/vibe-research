import json, os, shutil, subprocess, sys

USERPROFILE = os.environ["USERPROFILE"]
OPENCODE_SKILLS = os.path.join(USERPROFILE, ".config", "opencode", "skills")
OPENCODE_AGENTS = os.path.join(USERPROFILE, ".config", "opencode", "agents")
OPENCODE_CONFIG = os.path.join(USERPROFILE, ".config", "opencode", "opencode.json")
VIBE_DIR = os.path.join(USERPROFILE, "vibe-research")

REQUIRED_SKILLS = [
    os.path.join("research", "SKILL.md"),
    os.path.join("search", "SKILL.md"),
    os.path.join("jot-collaboration", "SKILL.md"),
]

def resolve(path):
    return os.path.normpath(path)

def needs_copy():
    for rel in REQUIRED_SKILLS:
        target = resolve(os.path.join(OPENCODE_SKILLS, rel))
        if not os.path.exists(target):
            return True
    return False

def copy_skills():
    print("[8/10] Copying skills...")
    os.makedirs(OPENCODE_SKILLS, exist_ok=True)
    src = resolve(os.path.join(VIBE_DIR, "skills"))
    if os.path.exists(src):
        shutil.copytree(src, OPENCODE_SKILLS, dirs_exist_ok=True)
        print("Skills copied.")
    else:
        print(f"Source skills directory not found: {src}")

def copy_subagent():
    print("Copying subagent...")
    os.makedirs(OPENCODE_AGENTS, exist_ok=True)
    src = resolve(os.path.join(VIBE_DIR, ".opencode", "agents"))
    if os.path.exists(src):
        shutil.copytree(src, OPENCODE_AGENTS, dirs_exist_ok=True)
        print("Subagent copied.")
    else:
        print(f"Source agents directory not found: {src}")

def copy_session_registry():
    print("Copying session registry reference...")
    dest_dir = resolve(os.path.join(OPENCODE_SKILLS, "research", "references"))
    os.makedirs(dest_dir, exist_ok=True)
    src = resolve(os.path.join(VIBE_DIR, "skills", "research", "references", "session-registry.md"))
    if os.path.exists(src):
        shutil.copy2(src, dest_dir)
        print("Session registry reference copied.")
    else:
        print(f"Session registry source not found: {src}")

def copy_config():
    if os.path.exists(OPENCODE_CONFIG):
        print(f"OpenCode config already exists — skipping (delete it to re-apply)")
        return
    print("Copying opencode config...")
    os.makedirs(os.path.dirname(OPENCODE_CONFIG), exist_ok=True)
    src = resolve(os.path.join(VIBE_DIR, "config", "opencode.json"))
    if os.path.exists(src):
        shutil.copy2(src, OPENCODE_CONFIG)
        print(f"OpenCode config copied.")
    else:
        print(f"Config source not found: {src}")

def main():
    if not os.path.exists(VIBE_DIR):
        print("vibe-research directory not found. Run setup from the beginning.")
        sys.exit(1)

    if needs_copy():
        copy_skills()
        copy_subagent()
        copy_session_registry()
    else:
        print("[8/10] Skills already copied. Skipping.")

    copy_config()

if __name__ == "__main__":
    main()
