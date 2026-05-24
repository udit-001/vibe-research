import json, os, sys

template_path = sys.argv[1]
settings_path = sys.argv[2]
starting_dir = sys.argv[3]

with open(template_path) as f:
    template = json.load(f)

for profile in template.get("profiles", {}).get("list", []):
    if profile.get("name") == "Git Bash":
        profile["startingDirectory"] = starting_dir
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

with open(settings_path, 'w') as f:
    json.dump(template, f, indent=4)
