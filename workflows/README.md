# Example Workflows for n8n AI Starter Kit

This directory contains example workflows demonstrating the use of various Python and JavaScript modules in n8n Code nodes with external task runners.

## Available Examples

### 1. Cryptography Examples

#### Python: `example-cryptography-python.json`
Demonstrates Python's built-in security modules:
- **hashlib** - Hash strings with MD5, SHA1, SHA256, SHA512
- **hmac** - Create HMAC signatures for API authentication
- **secrets** - Generate cryptographically secure random tokens
- **uuid** - Generate UUIDs (version 4)
- **PBKDF2** - Secure password hashing with salt

**Use cases:**
- API authentication and signing
- Generating unique IDs and tokens
- Password storage and verification
- Data integrity verification

#### JavaScript: `example-cryptography-javascript.json`
Demonstrates Node.js built-in crypto module:
- Hash strings with multiple algorithms
- HMAC signatures
- Generate random tokens
- AES-256-GCM encryption
- Generate UUIDs

**Use cases:**
- Same as Python but using JavaScript
- Webhooks requiring signatures
- Token generation
- Data encryption

### 2. File Processing Examples

#### Python: `example-file-processing-python.json`
Demonstrates file operations and data processing:
- **csv** - Parse CSV files
- **pathlib** - Modern file path handling
- **tempfile** - Create secure temporary files
- **yaml** - Parse YAML configuration files (NEW!)
- **json** - JSON data interchange

**Use cases:**
- Processing uploaded CSV/Excel files
- Working with configuration files
- Temporary data storage
- File path manipulation
- Kubernetes YAML parsing

### 3. Timezone Examples

#### Python: `example-timezone-python.json`
Demonstrates advanced timezone handling:
- **pytz** - Convert between timezones
- Get current time in multiple world cities
- Parse dates in various formats
- Handle daylight saving time automatically

**Use cases:**
- Scheduling across timezones
- World clock displays
- International applications
- Meeting scheduler
- Timestamp conversion

## How to Use These Examples

### Option 1: Import via n8n UI

1. Open n8n at https://n8n.daho.ai
2. Click "Import from File"
3. Select the example workflow JSON file
4. Modify for your needs
5. Execute the workflow

### Option 2: Copy Code Snippets

1. Open the example JSON file in a text editor
2. Copy the Python/JavaScript code
3. Paste into a Code node in your workflow
4. Adjust as needed

## Dependencies

All examples use modules that are already configured:

### Python Standard Library (Built-in)
✅ All available via `N8N_RUNNERS_STDLIB_ALLOW=*`

### Python External Packages (Installed)
✅ `cryptography` - Modern crypto library
✅ `pyyaml` - YAML parsing
✅ `pytz` - Timezone handling
✅ `numpy`, `pandas`, `requests`, etc.

### JavaScript
✅ Built-in `crypto` module
✅ All configured in `n8n-task-runners.json`

## Customizing Examples

### Adding Your Own Modules

#### For Python Standard Library
No installation needed! All modules are already available. Just import and use:
```python
import os
import sys
import hashlib
# ... etc
```

#### For Python External Packages
1. Add to `Dockerfile.runners`:
```dockerfile
RUN uv pip install --system \
    your-package
```

2. Rebuild and redeploy:
```bash
./deploy-vps.sh
```

3. Use in your Code node:
```python
import your_package
```

## Example Use Cases

### API Authentication with HMAC
```python
import hmac
import hashlib

def sign_request(request_body, secret_key):
    signature = hmac.new(
        secret_key.encode('utf-8'),
        request_body.encode('utf-8'),
        hashlib.sha256
    ).hexdigest()
    return signature

# Use for APIs that require signed requests
return sign_request($json.body, 'my-secret-key')
```

### Generate Unique IDs
```python
import secrets

return {
    'url_safe_token': secrets.token_urlsafe(16),
    'hex_token': secrets.token_hex(16),
    'uuid': str(uuid.uuid4())
}
```

### Process CSV Data
```python
import csv
import io

csv_data = $input.all

# Parse CSV
reader = csv.DictReader(io.StringIO(csv_data))
rows = list(reader)

return [{
    'name': row['name'],
    'processed': True
} for row in rows]
```

### World Clock Feature
```python
from datetime import datetime
import pytz

cities = {
    'New York': 'America/New_York',
    'London': 'Europe/London',
    'Tokyo': 'Asia/Tokyo'
}

utc_now = datetime.now(pytz.UTC)

return [{
    'city': city,
    'time': utc_now.astimezone(pytz.timezone(tz)).strftime('%H:%M')
} for city, tz in cities.items()]
```

## Troubleshooting

### Module Not Found Error

**Error**: `ModuleNotFoundError: No module named 'X'`

**Solution**:
1. Check if it's a standard library module - should work automatically
2. Check if it's installed in `Dockerfile.runners`
3. Redeploy with `./deploy-vps.sh`

### Import Still Blocked

**Error**: "Import of module 'X' is disallowed"

**Solution**:
1. Verify `N8N_RUNNERS_STDLIB_ALLOW=*` in docker-compose.yml line 103
2. Verify `n8n-task-runners.json` has the module in `allowed-env`
3. Restart runners: `docker compose restart n8n-runners`

## More Examples

For complete documentation on all available modules and examples, see **`PYTHON_EXAMPLES.md`** in the root directory.

## Contributing

Have a useful example? Add it to this directory!
1. Create a new JSON file following the naming pattern
2. Include clear comments in the code
3. Update this README
4. Submit a pull request

---

All examples are production-ready and can be used immediately in your n8n workflows! 🚀
