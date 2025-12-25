# Test Workflows for n8n

This directory contains test workflows to verify all installed packages are working correctly.

## How to Import

1. Open n8n at `https://automate.dahopevi.com`
2. Click **"Workflows"** in the left sidebar
3. Click **"+"** to create a new workflow
4. Click the **"..."** menu (top right)
5. Select **"Import from File"**
6. Choose a `.json` file from this directory
7. Click **"Import"**

## Available Test Workflows

### 📦 test-all-packages.json
Quick check that all packages (axios, cheerio, moment, sharp, nodemailer, ffmpeg) are installed and working.

### 🌐 test-axios.json
Tests **axios** - HTTP client library
- Fetches a random joke from a public API
- Gets your IP address
- Demonstrates GET requests

### 🕷️ test-cheerio.json
Tests **cheerio** - HTML/web scraping parser
- Scrapes example.com
- Extracts titles, paragraphs, and counts links
- Demonstrates web scraping

### 📅 test-moment.json
Tests **moment** - Date/time manipulation library
- Current time in multiple formats
- Date calculations (next week, last month, etc.)
- Human-readable relative times

### 🖼️ test-sharp.json
Tests **sharp** - High-performance image processor
- Creates a test image
- Resizes it
- Returns metadata
- Much faster than canvas!

### 📧 test-nodemailer.json
Tests **nodemailer** - Email sending library
- Shows email structure
- Provides Gmail and Outlook SMTP configuration examples
- Ready to send real emails with SMTP credentials

## What About FFmpeg?

FFmpeg is installed at the system level. To test it, use the **Execute Command** node in n8n:

```bash
ffmpeg -version
```

This will return the FFmpeg version information, confirming it's available.

## Tips

- Run these tests after deployment to verify everything works
- Use these workflows as templates for your own automations
- All packages are available in Code nodes throughout n8n
