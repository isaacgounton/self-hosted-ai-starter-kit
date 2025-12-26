# Task Runners Configuration - COMPLETE GUIDE

This is the complete, working solution for enabling Python and JavaScript modules in n8n Code nodes using external task runners.

## The Problem

Starting from n8n v1.111.0, Python Code nodes use a new "Python (Native)" runtime that:
- Blocks **ALL** Python standard library modules by default (security feature)
- Blocks **ALL** external Python packages by default
- Requires explicit configuration via `n8n-task-runners.json`

## The Solution

We use a two-part configuration:

1. **`n8n-task-runners.json`** - Defines which environment variables are allowed
2. **`docker-compose.yml`** - Sets those environment variables

### File 1: `n8n-task-runners.json`

This file is **critical** - it tells the task runners which environment variables they're allowed to read. The key is adding `N8N_RUNNERS_STDLIB_ALLOW` and `N8N_RUNNERS_EXTERNAL_ALLOW` to the `allowed-env` array:

```json
{
	"task-runners": [
		{
			"runner-type": "javascript",
			"workdir": "/home/runner",
			"command": "/usr/local/bin/node",
			"args": [
				"--disallow-code-generation-from-strings",
				"--disable-proto=delete",
				"/opt/runners/task-runner-javascript/dist/start.js"
			],
			"health-check-server-port": "5681",
			"allowed-env": [
				"PATH",
				"GENERIC_TIMEZONE",
				"NODE_OPTIONS",
				"N8N_RUNNERS_AUTO_SHUTDOWN_TIMEOUT",
				"N8N_RUNNERS_TASK_TIMEOUT",
				"N8N_RUNNERS_MAX_CONCURRENCY",
				"N8N_SENTRY_DSN",
				"N8N_VERSION",
				"ENVIRONMENT",
				"DEPLOYMENT_NAME"
			],
			"env-overrides": {
				"NODE_FUNCTION_ALLOW_BUILTIN": "",
				"NODE_FUNCTION_ALLOW_EXTERNAL": "axios,cheerio,moment,canvas,ffmpeg,jszip,nodemailer",
				"N8N_RUNNERS_HEALTH_CHECK_SERVER_HOST": "0.0.0.0"
			}
		},
		{
			"runner-type": "python",
			"workdir": "/home/runner",
			"command": "/opt/runners/task-runner-python/.venv/bin/python",
			"args": ["-m", "src.main"],
			"health-check-server-port": "5682",
			"allowed-env": [
				"PATH",
				"N8N_RUNNERS_LAUNCHER_LOG_LEVEL",
				"N8N_RUNNERS_AUTO_SHUTDOWN_TIMEOUT",
				"N8N_RUNNERS_TASK_TIMEOUT",
				"N8N_RUNNERS_MAX_CONCURRENCY",
				"N8N_RUNNERS_STDLIB_ALLOW",
				"N8N_RUNNERS_EXTERNAL_ALLOW",
				"N8N_SENTRY_DSN",
				"N8N_VERSION",
				"ENVIRONMENT",
				"DEPLOYMENT_NAME"
			],
			"env-overrides": {
				"PYTHONPATH": "/opt/runners/task-runner-python",
				"N8N_RUNNERS_EXTERNAL_ALLOW": ""
			}
		}
	]
}
```

**KEY POINTS:**
- Lines 43-44: `N8N_RUNNERS_STDLIB_ALLOW` and `N8N_RUNNERS_EXTERNAL_ALLOW` **MUST** be in `allowed-env`
- Line 52: `N8N_RUNNERS_EXTERNAL_ALLOW` can be empty ("") - this allows all packages
- Note the command paths have **NO trailing slashes**

### File 2: `docker-compose.yml`

```yaml
n8n-runners:
  build:
    context: .
    dockerfile: Dockerfile.runners
  hostname: n8n-runners
  container_name: n8n-runners
  networks: ['n8n-ai-network']
  restart: unless-stopped
  volumes:
    - ./n8n-task-runners.json:/etc/n8n-task-runners.json:ro  # ← MOUNT THE CONFIG FILE
  environment:
    - N8N_RUNNERS_MODE=external
    - N8N_RUNNERS_TASK_BROKER_URI=http://n8n:5679
    - N8N_RUNNERS_AUTH_TOKEN=${N8N_RUNNERS_AUTH_TOKEN}
    - N8N_RUNNERS_STDLIB_ALLOW=*  # ← Allow ALL Python stdlib modules
    - N8N_RUNNERS_EXTERNAL_ALLOW=*  # ← Allow ALL Python external packages
  env_file:
    - .env
  depends_on:
    n8n:
      condition: service_started
```

**KEY POINTS:**
- Line 97: Mount the JSON config file into the container
- Lines 103-105: Set environment variables (using `*` allows everything)

### File 3: `Dockerfile.runners`

Install Python packages that will be available:

```dockerfile
FROM n8nio/runners:latest

USER root

RUN uv pip install --system \
    numpy \
    pandas \
    requests \
    beautifulsoup4 \
    lxml \
    openpyxl \
    xlrd \
    matplotlib \
    seaborn \
    pillow \
    && uv cache clean

USER runner
```

## Current Status ✅

```
✓ Task Broker ready on 0.0.0.0, port 5679
✓ Registered runner "launcher-javascript"
✓ Registered runner "launcher-python"
✓ Python subprocess/sys modules allowed
✓ All Python standard library modules allowed
✓ All Python external packages allowed
```

## Python Modules Now Available

### Standard Library (ALL modules via `N8N_RUNNERS_STDLIB_ALLOW=*`)
- `subprocess` - Run external commands (FFmpeg, etc.)
- `sys` - System-specific parameters
- `os` - Operating system interface
- `json` - JSON encoder/decoder
- `re` - Regular expressions
- `datetime` - Date/time operations
- `pathlib` - File paths
- `collections` - Specialized containers
- ...and **ALL other standard library modules**

### External Packages (installed in Dockerfile.runners)
- `numpy` - Numerical computing
- `pandas` - Data manipulation
- `requests` - HTTP library
- `beautifulsoup4` - HTML parsing
- `lxml` - XML processing
- `openpyxl` - Excel writing
- `xlrd` - Excel reading
- `matplotlib` - Plotting
- `seaborn` - Statistical visualization
- `pillow` - Image processing

## How to Deploy

```bash
./deploy-vps.sh
```

This script:
1. Uploads `docker-compose.yml`
2. Uploads `Dockerfile` and `Dockerfile.runners`
3. Uploads `n8n-task-runners.json`
4. Uploads `.env`
5. Rebuilds images if needed
6. Restarts all services
7. Task runners auto-connect

## Troubleshooting

### Error: "Import of standard library module 'X' is disallowed"

**Cause**: The `n8n-task-runners.json` file is missing `N8N_RUNNERS_STDLIB_ALLOW` in the `allowed-env` array.

**Solution**:
1. Check that line 43 of `n8n-task-runners.json` has `"N8N_RUNNERS_STDLIB_ALLOW"`
2. Check that line 97 of `docker-compose.yml` mounts the file
3. Check that line 103 of `docker-compose.yml` sets `N8N_RUNNERS_STDLIB_ALLOW=*`
4. Redeploy with `./deploy-vps.sh`

### Error: "failed to chdir into configured dir"

**Cause**: Incorrect format in `n8n-task-runners.json` (usually trailing slashes or wrong format)

**Solution**:
1. Check that command paths have NO trailing slash (e.g., `/usr/local/bin/node` not `/usr/local/bin/node/`)
2. Check that workdir has NO trailing slash (e.g., `/home/runner` not `/home/runner/`)
3. Check that port numbers are strings (e.g., `"5681"` not `5681`)

### Changes not taking effect

**Solution**: Restart the runners:
```bash
ssh root@YOUR_VPS
cd /opt/n8n-ai-starter-kit
docker compose restart n8n-runners
```

Or redeploy completely:
```bash
./deploy-vps.sh
```

## Security Considerations

⚠️ **Using `N8N_RUNNERS_STDLIB_ALLOW=*` allows ALL Python standard library modules**

This includes powerful modules like:
- `subprocess` - Can execute any system command
- `os` - Can access the file system
- `sys` - Can modify Python runtime

**Only use this if:**
- You trust all users who will create workflows
- This is a private/self-hosted instance
- You understand the security implications

**To restrict access**, change line 103 in `docker-compose.yml`:
```yaml
- N8N_RUNNERS_STDLIB_ALLOW=json,re,datetime  # Only allow specific modules
```

## Files Modified

1. **`n8n-task-runners.json`** - Task runner configuration (NEW)
2. **`docker-compose.yml`** - Mounts JSON file and sets env vars
3. **`Dockerfile.runners`** - Installs Python packages
4. **`deploy-vps.sh`** - Includes JSON file in deployment

## Reference

This solution is based on the official n8n community forum discussion:
https://community.n8n.io/t/libraries-desallowed-in-n8n-code-node-n8n-cloud/203666/10

Key insight from the forum: "You have to mount the `n8n-task-runners.json` file and add `N8N_RUNNERS_STDLIB_ALLOW` to the `allowed-env` array."
