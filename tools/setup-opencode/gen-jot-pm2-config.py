import json, sys, os, subprocess

def find_jot_server():
    """Find the server entry point, preferring dist/server.js over cli/jot.mjs.

    cli/jot.mjs has a Windows bug: new URL(import.meta.url).pathname
    prepends a '/' to the drive letter, creating invalid paths like
    '/C:/Users/...'. dist/server.js handles CLI args directly and works
    on all platforms.
    """
    try:
        npm_root = subprocess.check_output(["npm", "root", "-g"], text=True).strip()
    except Exception:
        npm_root = os.path.join(os.environ.get("APPDATA", ""), "npm", "node_modules")

    pkg_dir = os.path.join(npm_root, "@mariozechner", "jot")

    server = os.path.join(pkg_dir, "dist", "server.js")
    if os.path.exists(server):
        return server, False

    cli = os.path.join(pkg_dir, "cli", "jot.mjs")
    if os.path.exists(cli):
        return cli, True

    alt_server = os.path.join(os.environ.get("LOCALAPPDATA", ""), "npm", "node_modules",
                              "@mariozechner", "jot", "dist", "server.js")
    if os.path.exists(alt_server):
        return alt_server, False

    alt_cli = os.path.join(os.environ.get("LOCALAPPDATA", ""), "npm", "node_modules",
                           "@mariozechner", "jot", "cli", "jot.mjs")
    if os.path.exists(alt_cli):
        return alt_cli, True

    return None, False

def main():
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <output_path> [data_dir] [port]", file=sys.stderr)
        sys.exit(1)

    output_path = sys.argv[1]
    data_dir = sys.argv[2] if len(sys.argv) > 2 else os.path.join(os.path.expanduser("~"), "jot-data")
    port = sys.argv[3] if len(sys.argv) > 3 else "3210"

    entry, is_cli = find_jot_server()
    if not entry:
        print("ERROR: Could not find Jot entry point", file=sys.stderr)
        sys.exit(1)

    log_dir = os.path.join(data_dir, "logs")
    os.makedirs(log_dir, exist_ok=True)

    args = [f"--port={port}", f"--data={data_dir}"]
    if is_cli:
        args.insert(0, "serve")

    config = {
        "apps": [{
            "name": "jot",
            "script": entry.replace("\\", "/"),
            "args": args,
            "instances": 1,
            "exec_mode": "fork",
            "env": {"NODE_ENV": "production"},
            "log_file": os.path.join(log_dir, "combined.log").replace("\\", "/"),
            "out_file": os.path.join(log_dir, "out.log").replace("\\", "/"),
            "error_file": os.path.join(log_dir, "error.log").replace("\\", "/"),
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
