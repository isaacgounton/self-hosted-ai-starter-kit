# VPS Deployment Guide

This guide will help you deploy the n8n AI Starter Kit to your VPS using Caddy as a reverse proxy.

## Prerequisites

- VPS with Ubuntu/Debian Linux
- Root or sudo access
- Domain pointed to your VPS (daho.ai)
- SSH access to VPS

## Quick Deploy

Run the automated deployment script:

```bash
chmod +x deploy-vps.sh
./deploy-vps.sh
```

The script will:
1. Connect to your VPS using credentials from `.env`
2. Install Docker, Docker Compose, and Caddy
3. Upload application files
4. Configure Caddy reverse proxy with SSL
5. Deploy the application

## Manual Deployment

### Step 1: Connect to VPS

```bash
ssh root@158.220.107.177
# Use password from .env file
```

### Step 2: Install Dependencies

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
systemctl enable docker
systemctl start docker

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Install Caddy
apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list
apt update
apt install caddy
```

### Step 3: Upload Application Files

From your local machine:

```bash
# Create directory on VPS
ssh root@158.220.107.177 "mkdir -p /opt/n8n-ai-starter-kit"

# Upload files (replace with your password)
scp -r docker-compose.yml Dockerfile .env n8n/ workflows/ root@158.220.107.177:/opt/n8n-ai-starter-kit/
```

### Step 4: Configure Caddy

Upload the Caddyfile:

```bash
scp Caddyfile.daho.ai root@158.220.107.177:/etc/caddy/Caddyfile
```

On the VPS:

```bash
# Validate Caddy configuration
caddy validate --config /etc/caddy/Caddyfile

# Restart Caddy
systemctl restart caddy
systemctl enable caddy
```

### Step 5: Deploy Application

```bash
cd /opt/n8n-ai-starter-kit
docker compose up -d
```

## Access Your Services

After deployment, your services will be available at:

- **n8n**: https://n8n.daho.ai
- **Qdrant**: https://qdrant.daho.ai
- **MinIO API**: https://minio.daho.ai
- **MinIO Console**: https://minio-console.daho.ai

## Coolify Integration

To add these domains to Coolify:

1. In Coolify, create a new project or use existing one
2. Add new resources with these domains:
   - `n8n.daho.ai` (Proxy to localhost:5678)
   - `qdrant.daho.ai` (Proxy to localhost:6333)
   - `minio.daho.ai` (Proxy to localhost:9000)
   - `minio-console.daho.ai` (Proxy to localhost:9001)
3. Coolify will automatically obtain SSL certificates

## DNS Configuration

Make sure your DNS records are configured:

```
Type    Name              Value
A       n8n               158.220.107.177
A       qdrant            158.220.107.177
A       minio             158.220.107.177
A       minio-console     158.220.107.177
```

Or use wildcard DNS:
```
Type    Name    Value
A       *       158.220.107.177
```

## Troubleshooting

### Check service status

```bash
# Docker containers
docker compose ps

# Caddy status
systemctl status caddy

# View logs
docker compose logs -f
```

### Restart services

```bash
# Restart application
cd /opt/n8n-ai-starter-kit
docker compose restart

# Restart Caddy
systemctl restart caddy
```

### Test Caddy configuration

```bash
caddy validate --config /etc/caddy/Caddyfile
```

## Security Notes

- Change default passwords in `.env` before deployment
- Use firewall to restrict access: `ufw allow 80/tcp && ufw allow 443/tcp`
- Keep Docker and Caddy updated
- Regularly update n8n and dependencies

## Environment Variables

Required in `.env`:

```bash
# VPS Credentials
VPS_HOST=158.220.107.177
VPS_SSH_USER=root
VPS_PASSWORD=your_password

# Application
POSTGRES_USER=root
POSTGRES_PASSWORD=secure_password
POSTGRES_DB=n8n

N8N_ENCRYPTION_KEY=generate_with_openssl_rand
N8N_USER_MANAGEMENT_JWT_SECRET=generate_with_openssl_rand
SERVICE_URL_N8N=https://n8n.daho.ai

# MinIO
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=secure_password
```

Generate secure keys:
```bash
openssl rand -base64 32
```
