#!/bin/bash

# ============================================================
# Simple VPS Deployment Script for n8n AI Starter Kit
# This script deploys the app to your VPS via SSH
# Caddy must be configured manually
# ============================================================

set -e

# Load environment variables
if [ ! -f .env ]; then
    echo "❌ Error: .env file not found!"
    exit 1
fi

source .env

# VPS Configuration
VPS_HOST="${VPS_HOST}"
VPS_USER="${VPS_SSH_USER:-root}"
VPS_PASSWORD="${VPS_PASSWORD}"
VPS_SSH_KEY="${VPS_SSH_KEY_PATH:-~/.ssh/id_rsa}"
VPS_PORT="${VPS_PORT:-22}"
REMOTE_DIR="/opt/n8n-ai-starter-kit"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== VPS Deployment Script ===${NC}"
echo -e "${BLUE}Target:${NC} ${VPS_USER}@${VPS_HOST}"
echo ""

# Check required variables
if [ -z "$VPS_HOST" ] || [ -z "$VPS_USER" ]; then
    echo "❌ VPS_HOST and VPS_SSH_USER must be set in .env"
    exit 1
fi

# Test SSH connection
echo -e "${GREEN}→ Testing SSH connection...${NC}"
SSH_TEST_CMD=""
if [ -n "$VPS_PASSWORD" ]; then
    SSH_TEST_CMD="sshpass -p '${VPS_PASSWORD}' ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -p ${VPS_PORT} ${VPS_USER}@${VPS_HOST}"
elif [ -f "$VPS_SSH_KEY" ]; then
    SSH_TEST_CMD="ssh -i '${VPS_SSH_KEY}' -o StrictHostKeyChecking=no -o PasswordAuthentication=no -o ConnectTimeout=5 -p ${VPS_PORT} ${VPS_USER}@${VPS_HOST}"
else
    echo "❌ Neither VPS_PASSWORD nor valid SSH key found. Please set VPS_PASSWORD in .env or ensure SSH key exists."
    exit 1
fi

if ! eval "$SSH_TEST_CMD 'echo Connected'" 2>/dev/null; then
    echo "❌ Cannot connect to VPS. Please check your credentials."
    exit 1
fi

# Prepare remote server
echo -e "${GREEN}→ Preparing remote server...${NC}"
SSH_CMD=""
if [ -n "$VPS_PASSWORD" ]; then
    SSH_CMD="sshpass -p '${VPS_PASSWORD}' ssh -o StrictHostKeyChecking=no -p ${VPS_PORT} ${VPS_USER}@${VPS_HOST}"
else
    SSH_CMD="ssh -i '${VPS_SSH_KEY}' -o StrictHostKeyChecking=no -o PasswordAuthentication=no -p ${VPS_PORT} ${VPS_USER}@${VPS_HOST}"
fi

eval "$SSH_CMD" << 'ENDSSH'
    # Create directory
    mkdir -p /opt/n8n-ai-starter-kit

    # Install Docker if not present
    if ! command -v docker &> /dev/null; then
        echo "Installing Docker..."
        curl -fsSL https://get.docker.com -o get-docker.sh
        sh get-docker.sh
        systemctl enable docker
        systemctl start docker
    fi

    # Install Docker Compose if not present
    if ! docker compose version &> /dev/null && ! command -v docker-compose &> /dev/null; then
        echo "Installing Docker Compose..."
        curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose
    fi

    echo "✓ Server preparation complete"
ENDSSH

# Upload files using rsync (more efficient than scp)
echo -e "${GREEN}→ Uploading files...${NC}"
if command -v rsync &> /dev/null; then
    SSH_OPT=""
    if [ -n "$VPS_PASSWORD" ]; then
        SSH_OPT="sshpass -p '${VPS_PASSWORD}' ssh -o StrictHostKeyChecking=no -p ${VPS_PORT}"
    else
        SSH_OPT="ssh -i ${VPS_SSH_KEY} -o StrictHostKeyChecking=no -o PasswordAuthentication=no -p ${VPS_PORT}"
    fi
    
    # Build rsync command with existing directories
    RSYNC_CMD="rsync -avz --progress -e \"$SSH_OPT\" --exclude 'node_modules' --exclude '.git' --exclude '*.log' docker-compose.yml Dockerfile Dockerfile.runners n8n-task-runners.json .env n8n/"
    
    # Add directories if they exist
    [ -d "workflows" ] && RSYNC_CMD="$RSYNC_CMD workflows/"
    
    # Execute rsync
    eval "$RSYNC_CMD ${VPS_USER}@${VPS_HOST}:${REMOTE_DIR}/"
else
    # Fallback to scp
    if [ -n "$VPS_PASSWORD" ]; then
        SCP_CMD="sshpass -p '${VPS_PASSWORD}' scp -o StrictHostKeyChecking=no -P ${VPS_PORT} -r docker-compose.yml Dockerfile Dockerfile.runners n8n-task-runners.json .env n8n/"
    else
        SCP_CMD="scp -i ${VPS_SSH_KEY} -o StrictHostKeyChecking=no -o PasswordAuthentication=no -P ${VPS_PORT} -r docker-compose.yml Dockerfile Dockerfile.runners n8n-task-runners.json .env n8n/"
    fi
    
    # Add directories if they exist
    [ -d "workflows" ] && SCP_CMD="$SCP_CMD workflows/"
    
    # Execute scp
    eval "$SCP_CMD ${VPS_USER}@${VPS_HOST}:${REMOTE_DIR}/"
fi

# Deploy application
echo -e "${GREEN}→ Deploying application...${NC}"
if [ -n "$VPS_PASSWORD" ]; then
    DEPLOY_CMD="sshpass -p '${VPS_PASSWORD}' ssh -o StrictHostKeyChecking=no -p ${VPS_PORT} ${VPS_USER}@${VPS_HOST}"
else
    DEPLOY_CMD="ssh -i '${VPS_SSH_KEY}' -o StrictHostKeyChecking=no -o PasswordAuthentication=no -p ${VPS_PORT} ${VPS_USER}@${VPS_HOST}"
fi

eval "$DEPLOY_CMD" << 'ENDSSH'
    cd /opt/n8n-ai-starter-kit

    # Stop existing containers
    docker compose down 2>/dev/null || true

    # Pull latest images
    docker compose pull

    # Start services
    docker compose up -d

    # Wait for services
    sleep 5

    # Show status
    docker compose ps
ENDSSH

echo ""
echo -e "${GREEN}✓ Deployment complete!${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Configure Caddy reverse proxy (see Caddyfile.daho.ai)"
echo "2. Access your services:"
echo "   - n8n: https://n8n.daho.ai"
echo "   - Qdrant: https://qdrant.daho.ai"
echo "   - MinIO: https://minio.daho.ai"
echo "   - MinIO Console: https://minio-console.daho.ai"
echo ""
echo -e "${YELLOW}To view logs:${NC}"
echo "  ssh -p ${VPS_PORT} ${VPS_USER}@${VPS_HOST}"
echo "  cd ${REMOTE_DIR}"
echo "  docker compose logs -f"
