import json, os, sys, shutil

def find_git_bash():
    git_exe = shutil.which("git")
    if not git_exe:
        return None
    git_dir = os.path.dirname(os.path.realpath(git_exe))
    candidates = [
        os.path.join(git_dir, "..", "bin", "bash.exe"),
        os.path.join(git_dir, "..", "usr", "bin", "bash.exe"),
    ]
    for c in candidates:
        path = os.path.normpath(c)
        if os.path.exists(path):
            return path
    return None

def find_git_icon():
    git_exe = shutil.which("git")
    if not git_exe:
        return None
    git_dir = os.path.dirname(os.path.realpath(git_exe))
    candidates = [
        os.path.join(git_dir, "..", "mingw64", "share", "git", "git-for-windows.ico"),
        os.path.join(git_dir, "..", "..", "mingw64", "share", "git", "git-for-windows.ico"),
    ]
    for c in candidates:
        path = os.path.normpath(c)
        if os.path.exists(path):
            return path
    return None

template_path = sys.argv[1]
settings_path = sys.argv[2]
starting_dir = sys.argv[3]

with open(template_path) as f:
    template = json.load(f)

bash_path = find_git_bash()
icon_path = find_git_icon()

for profile in template.get("profiles", {}).get("list", []):
    if profile.get("name") == "Git Bash":
        profile["startingDirectory"] = starting_dir
        if bash_path:
            profile["commandline"] = f'"{bash_path}" -li'
            profile.pop("source", None)
        if icon_path:
            profile["icon"] = icon_path
        break

if os.path.exists(settings_path):
    with open(settings_path) as f:
        existing = json.load(f)

    others = [p for p in existing.get("profiles", {}).get("list", [])
              if p.get("name") != "Git Bash"]
    template["profiles"]["list"].extend(others)

    for key in ("actions", "keybindings", "copyFormatting"):
        if key in existing:
            template[key] = existing[key]

with open(settings_path, "w") as f:
    json.dump(template, f, indent=4)
