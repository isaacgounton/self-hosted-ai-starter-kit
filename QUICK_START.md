# Quick Start - VPS Deployment

## Files Created

1. **deploy-vps-simple.sh** - Simple deployment script (recommended)
2. **deploy-vps.sh** - Full deployment script with password auth
3. **Caddyfile.daho.ai** - Caddy reverse proxy configuration
4. **DEPLOYMENT.md** - Full deployment guide

## Quick Deployment

### Option 1: Simple Deployment (Recommended)

```bash
./deploy-vps-simple.sh
```

This script:
- Connects to your VPS using SSH key or password
- Installs Docker and Docker Compose if needed
- Uploads application files
- Deploys the application
- **Does NOT touch Caddy** (you'll configure it manually)

### Option 2: Full Deployment with Password

```bash
./deploy-vps.sh
```

Similar to Option 1 but uses sshpass for password authentication.

## Manual Caddy Configuration

After deployment, configure Caddy manually on your VPS:

```bash
# SSH into your VPS
ssh root@158.220.107.177

# Copy the Caddyfile
scp Caddyfile.daho.ai root@158.220.107.177:/etc/caddy/Caddyfile

# On VPS: Validate and restart Caddy
caddy validate --config /etc/caddy/Caddyfile
systemctl restart caddy
```

Or use the configuration in Coolify by adding proxy resources.

## Caddy Configuration (daho.ai)

```caddy
# n8n - Workflow Automation
n8n.daho.ai {
    reverse_proxy localhost:5678
}

# Qdrant - Vector Database
qdrant.daho.ai {
    reverse_proxy localhost:6333
}

# MinIO API
minio.daho.ai {
    reverse_proxy localhost:9000
}

# MinIO Console
minio-console.daho.ai {
    reverse_proxy localhost:9001
}
```

Full configuration available in `Caddyfile.daho.ai`

## Access Points

- **n8n**: https://n8n.daho.ai
- **Qdrant**: https://qdrant.daho.ai
- **MinIO API**: https://minio.daho.ai
- **MinIO Console**: https://minio-console.daho.ai

## Environment Variables

Your `.env` contains:

```bash
VPS_HOST=158.220.107.177
VPS_SSH_USER=root
VPS_PASSWORD=****
```

## Troubleshooting

**Check service status:**
```bash
ssh root@158.220.107.177
cd /opt/n8n-ai-starter-kit
docker compose ps
```

**View logs:**
```bash
docker compose logs -f
```

**Restart services:**
```bash
docker compose restart
```

## Coolify Integration

To add these domains to Coolify:

1. Go to your Coolify instance
2. Create new resources → Proxy
3. Add each domain:
   - `n8n.daho.ai` → `localhost:5678`
   - `qdrant.daho.ai` → `localhost:6333`
   - `minio.daho.ai` → `localhost:9000`
   - `minio-console.daho.ai` → `localhost:9001`

Coolify will automatically configure SSL and proxy rules.
