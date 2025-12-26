# Python Module Examples - Task Runners Guide

Complete guide to using Python and JavaScript modules in n8n Code nodes with external task runners.

## Table of Contents
1. [Security & Cryptography](#security--cryptography)
2. [File Operations](#file-operations)
3. [Data Processing](#data-processing)
4. [Time & Timezone](#time--timezone)
5. [Networking](#networking)
6. [Available Modules](#available-modules)

---

## Security & Cryptography

### 📦 Packages
- **Built-in**: `hashlib`, `hmac`, `secrets` (via `N8N_RUNNERS_STDLIB_ALLOW=*`)
- **Installed**: `cryptography` (via Dockerfile.runners)

### Python Examples

#### 1. Hash a String
```python
import hashlib

def hash_text(text, algorithm='sha256'):
    hash_obj = hashlib.new(algorithm)
    hash_obj.update(text.encode('utf-8'))
    return hash_obj.hexdigest()

# Usage
return {
    'sha256': hash_text('Hello, World!', 'sha256'),
    'md5': hash_text('Hello, World!', 'md5'),
    'sha512': hash_text('Hello, World!', 'sha512')
}
```

#### 2. Generate Secure Token
```python
import secrets
import string

def generate_token(length=32):
    alphabet = string.ascii_letters + string.digits + '-_'
    return ''.join(secrets.choice(alphabet) for _ in range(length))

# Usage
return {
    'token': generate_token(32),
    'url_safe': secrets.token_urlsafe(16),
    'hex': secrets.token_hex(16)
}
```

#### 3. HMAC Signature (API Authentication)
```python
import hmac
import hashlib

def create_signature(message, secret):
    signature = hmac.new(
        secret.encode('utf-8'),
        message.encode('utf-8'),
        hashlib.sha256
    ).hexdigest()
    return signature

# Usage
return {
    'signature': create_signature('my-data', 'secret-key'),
    'verified': hmac.compare_digest(
        create_signature('my-data', 'secret-key'),
        create_signature('my-data', 'secret-key')
    )
}
```

#### 4. Using cryptography Package (Advanced)
```python
from cryptography.fernet import Fernet

def encrypt_message(message, key):
    f = Fernet(key)
    encrypted = f.encrypt(message.encode())
    return encrypted.decode()

def decrypt_message(encrypted, key):
    f = Fernet(key)
    decrypted = f.decrypt(encrypted.encode())
    return decrypted.decode()

# Generate key
from cryptography.fernet import Fernet
key = Fernet.generate_key()
return {
    'key': key.decode(),
    'encrypted': encrypt_message('Secret message', key),
    'decrypted': decrypt_message(encrypt_message('Secret message', key), key)
}
```

### JavaScript Examples

#### Built-in crypto Module (Already Configured)
```javascript
const crypto = require('crypto');

// Hash string
const hash = crypto.createHash('sha256')
  .update('Hello, World!')
  .digest('hex');

// HMAC signature
const hmac = crypto.createHmac('sha256', 'secret-key')
  .update('my-data')
  .digest('hex');

// Generate random token
const token = crypto.randomBytes(16).toString('hex');

// Generate UUID
const uuid = crypto.randomUUID();

return { hash, hmac, token, uuid };
```

---

## File Operations

### 📦 Built-in Modules (No Installation Needed)
- `pathlib` - Modern file path handling
- `tempfile` - Secure temporary file creation
- `shutil` - High-level file operations
- `zipfile` - ZIP archive handling
- `csv` - CSV file processing

### Examples

#### 1. Path Operations with pathlib
```python
from pathlib import Path

def analyze_path(file_path):
    p = Path(file_path)
    return {
        'name': p.name,
        'stem': p.stem,           # filename without extension
        'suffix': p.suffix,       # file extension
        'parent': str(p.parent),
        'exists': p.exists(),
        'is_absolute': p.is_absolute(),
        'parts': list(p.parts)
    }

# Usage
return analyze_path('/home/user/documents/report.pdf')
```

#### 2. Create Temporary File
```python
import tempfile

def create_temp_file(content, suffix='.txt'):
    with tempfile.NamedTemporaryFile(
        mode='w',
        prefix='n8n_',
        suffix=suffix,
        delete=False
    ) as f:
        f.write(content)
        return f.name

# Usage
temp_path = create_temp_file('Temporary data')
return {
    'temp_file': temp_path,
    'exists': Path(temp_path).exists()
}
```

#### 3. Process CSV Files
```python
import csv
import io

def parse_csv(csv_text):
    csv_file = io.StringIO(csv_text)
    reader = csv.DictReader(csv_file)
    rows = list(reader)

    return {
        'total_rows': len(rows),
        'columns': list(rows[0].keys()) if rows else [],
        'first_3_rows': rows[:3]
    }

# Usage
csv_data = '''name,age,city
Alice,30,NYC
Bob,25,SF
'''

return parse_csv(csv_data)
```

#### 4. Work with ZIP Files
```python
import zipfile
import io

def create_zip(files):
    zip_buffer = io.BytesIO()
    with zipfile.ZipFile(zip_buffer, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for filename, content in files.items():
            zipf.writestr(filename, content)

    zip_buffer.seek(0)
    return zip_buffer.read()

# Usage
return create_zip({
    'file1.txt': 'Content of file 1',
    'file2.txt': 'Content of file 2'
})
```

---

## Data Processing

### 📦 Installed Packages
- `numpy` - Numerical computing
- `pandas` - Data manipulation

### Examples

#### 1. Process Data with Pandas
```python
import pandas as pd
import io

def analyze_data(csv_data):
    df = pd.read_csv(io.StringIO(csv_data))

    return {
        'shape': df.shape,
        'columns': list(df.columns),
        'summary': df.describe().to_dict(),
        'first_3': df.head(3).to_dict('records')
    }

# Usage
csv_data = '''product,price,quantity
Widget A,10.50,100
Widget B,20.00,50
Widget C,15.75,75
'''

return analyze_data(csv_data)
```

#### 2. YAML Processing (NEW!)
```python
import yaml

def parse_yaml(yaml_content):
    config = yaml.safe_load(yaml_content)
    return {
        'config': config,
        'keys': list(config.keys()) if isinstance(config, dict) else []
    }

# Usage
yaml_content = '''
app:
  name: My App
  version: 1.0.0
  features:
    - auth
    - logging
'''

return parse_yaml(yaml_content)
```

---

## Time & Timezone

### 📦 Packages
- **Built-in**: `datetime`, `time`
- **Installed**: `pytz` (timezone handling)

### Examples

#### 1. Current Time in Multiple Cities
```python
from datetime import datetime
import pytz

def get_world_clocks():
    utc_now = datetime.now(pytz.UTC)

    cities = {
        'New York': 'America/New_York',
        'London': 'Europe/London',
        'Tokyo': 'Asia/Tokyo',
        'Sydney': 'Australia/Sydney'
    }

    results = {}
    for city, tz in cities.items():
        city_time = utc_now.astimezone(pytz.timezone(tz))
        results[city] = {
            'time': city_time.strftime('%H:%M:%S'),
            'date': city_time.strftime('%Y-%m-%d'),
            'timezone': tz
        }

    return results

return get_world_clocks()
```

#### 2. Convert Timezones (NEW!)
```python
from datetime import datetime
import pytz
from dateutil import parser

def convert_timezone(dt_str, from_tz, to_tz):
    dt = parser.parse(dt_str)
    if dt.tzinfo is None:
        dt = pytz.timezone(from_tz).localize(dt)

    converted = dt.astimezone(pytz.timezone(to_tz))
    return {
        'original': dt.isoformat(),
        'converted': converted.isoformat(),
        'timezone_abbr': converted.tzname()
    }

# Usage
return convert_timezone(
    '2024-01-15 10:00:00',
    'UTC',
    'America/New_York'
)
```

---

## Networking

### 📦 Built-in Modules
- `requests` - HTTP client (installed)
- `urllib` - URL handling (built-in)
- `http` - Low-level HTTP (built-in)
- `smtplib` - Email sending (built-in)

### Examples

#### 1. HTTP Request with requests
```python
import requests

def fetch_api(url):
    response = requests.get(url, timeout=10)
    return {
        'status': response.status_code,
        'headers': dict(response.headers),
        'content': response.text[:500]  # First 500 chars
    }

# Usage
return fetch_api('https://api.github.com')
```

#### 2. Send Email (smtplib)
```python
import smtplib
from email.mime.text import MIMEText

def send_email(to, subject, body):
    msg = MIMEText(body)
    msg['Subject'] = subject
    msg['From'] = 'noreply@example.com'
    msg['To'] = to

    # Configuration needed
    # smtp_server = smtplib.SMTP('smtp.gmail.com', 587)
    # smtp_server.send_message(msg)
    # smtp_server.quit()

    return {
        'to': to,
        'subject': subject,
        'body': body,
        'status': 'Configured (needs SMTP settings)'
    }

return send_email('user@example.com', 'Test', 'Email body')
```

---

## Available Modules

### Python Standard Library (ALL Allowed via `N8N_RUNNERS_STDLIB_ALLOW=*`)

#### Most Useful for Automation:

**Security & Crypto:**
- `hashlib` - Hashing algorithms (MD5, SHA, etc.)
- `hmac` - HMAC signatures
- `secrets` - Secure random generation
- `uuid` - UUID generation

**File Operations:**
- `pathlib` - Modern file paths
- `tempfile` - Temporary files
- `shutil` - File operations
- `zipfile` - ZIP archives
- `tarfile` - TAR archives
- `csv` - CSV files
- `json` - JSON parsing
- `xml` - XML processing

**Networking:**
- `urllib` - URL handling
- `http` - HTTP client
- `socket` - Low-level networking
- `smtplib` - SMTP email
- `ftplib` - FTP client

**Data Processing:**
- `re` - Regular expressions
- `datetime` - Date/time
- `collections` - Special containers
- `itertools` - Iteration tools
- `functools` - Function tools

**System:**
- `os` - Operating system
- `sys` - System parameters
- `subprocess` - Run commands
- `pathlib` - File paths
- `platform` - Platform info

### Python External Packages (Installed via Dockerfile.runners)

**Already Installed:**
- `numpy` - Numerical computing
- `pandas` - Data manipulation
- `requests` - HTTP client
- `beautifulsoup4` - HTML parsing
- `lxml` - XML processing
- `openpyxl` - Excel write
- `xlrd` - Excel read
- `matplotlib` - Plotting
- `seaborn` - Statistical visualization
- `pillow` - Image processing

**NEWLY Added:**
- `cryptography` - Modern crypto library ✨
- `pyyaml` - YAML parsing ✨
- `pytz` - Timezone handling ✨

### JavaScript Modules (Already Configured)

**Built-in (Already Allowed):**
- `crypto` - Cryptography ✅
- All other Node.js built-ins

**External (Already Allowed):**
- `axios` - HTTP client
- `cheerio` - HTML parsing
- `moment` - Date manipulation
- `canvas` - Image generation
- `ffmpeg` - Video processing
- `jszip` - ZIP creation
- `nodemailer` - Email sending

## Example Workflows Created

1. **`example-cryptography-python.json`** - Python crypto examples
   - Hash strings (MD5, SHA1, SHA256, SHA512)
   - HMAC signatures
   - Generate secure tokens
   - Generate UUIDs
   - Password hashing with PBKDF2

2. **`example-cryptography-javascript.json`** - JavaScript crypto examples
   - Hash strings
   - HMAC signatures
   - Generate random tokens
   - AES encryption
   - Generate UUIDs

3. **`example-file-processing-python.json`** - File operations
   - CSV processing
   - File path analysis
   - Temporary file creation
   - YAML parsing (NEW!)

4. **`example-timezone-python.json`** - Time utilities
   - World clock (multiple cities)
   - Timezone conversion
   - Date parsing (multiple formats)

## Quick Reference

### Import Security Modules
```python
# Built-in (already available)
import hashlib
import hmac
import secrets
import uuid
import zipfile
import tempfile
import csv
import yaml
import pytz

# External (need to be installed)
from cryptography.fernet import Fernet
import pandas as pd
import numpy as np
import requests
from bs4 import BeautifulSoup
```

### JavaScript Built-in Crypto
```javascript
// Already configured
const crypto = require('crypto');
```

## Next Steps

1. Deploy updated Dockerfile.runners:
   ```bash
   ./deploy-vps.sh
   ```

2. Import example workflows into n8n

3. Modify examples for your use case

4. Check **`TASK_RUNNERS.md`** for complete configuration details

---

All examples are ready to use! Just import the workflow files into n8n and run them. 🚀
