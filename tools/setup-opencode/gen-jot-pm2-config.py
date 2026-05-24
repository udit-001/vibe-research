import json, sys, os, subprocess

def find_jot_entry():
    candidates = []

    try:
        npm_root = subprocess.check_output(["npm", "root", "-g"], text=True).strip()
    except Exception:
        npm_root = os.path.join(os.environ.get("APPDATA", ""), "npm", "node_modules")

    pkg_dir = os.path.join(npm_root, "@mariozechner", "jot")

    pkg_json_path = os.path.join(pkg_dir, "package.json")
    if os.path.exists(pkg_json_path):
        with open(pkg_json_path) as f:
            pkg = json.load(f)
        bin_field = pkg.get("bin")
        if isinstance(bin_field, dict):
            for entry in bin_field.values():
                if entry:
                    candidates.append(os.path.join(pkg_dir, entry))
        elif isinstance(bin_field, str):
            candidates.append(os.path.join(pkg_dir, bin_field))
        main = pkg.get("main", "")
        if main:
            candidates.append(os.path.join(pkg_dir, main))

    candidates.append(os.path.join(pkg_dir, "cli", "jot.mjs"))
    candidates.append(os.path.join(pkg_dir, "dist", "server.js"))

    alt_dir = os.path.join(os.environ.get("LOCALAPPDATA", ""), "npm", "node_modules",
                           "@mariozechner", "jot")
    candidates.append(os.path.join(alt_dir, "cli", "jot.mjs"))
    candidates.append(os.path.join(alt_dir, "dist", "server.js"))

    for c in candidates:
        if c and os.path.exists(c):
            return c
    return None

def main():
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <output_path> [data_dir] [port]", file=sys.stderr)
        sys.exit(1)

    output_path = sys.argv[1]
    data_dir = sys.argv[2] if len(sys.argv) > 2 else os.path.join(os.path.expanduser("~"), "jot-data")
    port = sys.argv[3] if len(sys.argv) > 3 else "3210"

    entry = find_jot_entry()
    if not entry:
        print("ERROR: Could not find Jot entry point", file=sys.stderr)
        sys.exit(1)

    config = {
        "apps": [{
            "name": "jot",
            "script": entry.replace("\\", "/"),
            "args": ["serve", f"--port={port}", f"--data={data_dir}"],
            "instances": 1,
            "exec_mode": "fork",
            "env": {"NODE_ENV": "production"},
            "log_file": os.path.join(data_dir, "logs", "combined.log").replace("\\", "/"),
            "out_file": os.path.join(data_dir, "logs", "out.log").replace("\\", "/"),
            "error_file": os.path.join(data_dir, "logs", "error.log").replace("\\", "/"),
            "autorestart": True,
            "max_restarts": 10,
            "min_uptime": "10s"
        }]
    }

    with open(output_path, "w") as f:
        json.dump(config, f, indent=2)

    print(f"PM2 config written to {output_path}")

if __name__ == "__main__":
    main()
