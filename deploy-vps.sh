#!/bin/bash

# ============================================================
# VPS Deployment Script for n8n AI Starter Kit
# ============================================================

set -e  # Exit on error

# Load environment variables
if [ ! -f .env ]; then
    echo "Error: .env file not found!"
    exit 1
fi

source .env

# VPS Configuration
VPS_HOST="${VPS_HOST}"
VPS_USER="${VPS_SSH_USER}"
VPS_SSH_KEY="${VPS_SSH_KEY_PATH:-~/.ssh/id_rsa}"
VPS_PORT="${VPS_PORT:-22}"

# Deployment Configuration
REMOTE_DIR="/opt/n8n-ai-starter-kit"
DOMAIN="daho.ai"
APP_NAME="n8n-ai"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required variables are set
if [ -z "$VPS_HOST" ] || [ -z "$VPS_USER" ] || [ -z "$VPS_SSH_KEY" ]; then
    log_error "VPS credentials not found in .env file"
    log_error "Required: VPS_HOST, VPS_SSH_USER, VPS_SSH_KEY_PATH"
    exit 1
fi

log_info "=== VPS Deployment Script ==="
log_info "Target: ${VPS_USER}@${VPS_HOST}"
log_info "SSH Key: ${VPS_SSH_KEY}"
log_info "Remote directory: ${REMOTE_DIR}"
echo ""

# Create remote directory and setup
log_info "Creating remote directory structure..."
ssh -i "${VPS_SSH_KEY}" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${VPS_USER}@${VPS_HOST} -p ${VPS_PORT} << EOF
    # Create directory
    mkdir -p ${REMOTE_DIR}

    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        echo "Installing Docker..."
        curl -fsSL https://get.docker.com -o get-docker.sh
        sh get-docker.sh
        systemctl enable docker
        systemctl start docker
    fi

    # Check if Docker Compose is installed
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        echo "Installing Docker Compose..."
        curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-\$(uname -s)-\$(uname -m)" -o /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose
    fi

    echo "Remote setup complete!"
EOF

# Create Caddy configuration file locally
log_info "Creating Caddy configuration..."
cat > Caddyfile.${DOMAIN} << 'EOF'
# Caddy Configuration for n8n AI Starter Kit
# Base domain: daho.ai

# n8n - Workflow Automation
n8n.daho.ai {
    reverse_proxy localhost:5678

    # WebSocket support
    header_up Connection {>Connection}
    header_up Upgrade {>Upgrade}

    # Security headers
    header {
        X-Frame-Options "SAMEORIGIN"
        X-Content-Type-Options "nosniff"
        X-XSS-Protection "1; mode=block"
        Referrer-Policy "strict-origin-when-cross-origin"
        -Server
    }

    # Timeouts for long-running workflows
    transport http {
        read_timeout 300s
        write_timeout 300s
    }
}

# Qdrant - Vector Database
qdrant.daho.ai {
    reverse_proxy localhost:6333

    header {
        X-Frame-Options "SAMEORIGIN"
        X-Content-Type-Options "nosniff"
        -Server
    }
}

# MinIO API
minio.daho.ai {
    reverse_proxy localhost:9000

    header {
        X-Frame-Options "SAMEORIGIN"
        X-Content-Type-Options "nosniff"
        -Server
    }
}

# MinIO Console
minio-console.daho.ai {
    reverse_proxy localhost:9001

    header {
        X-Frame-Options "SAMEORIGIN"
        X-Content-Type-Options "nosniff"
        -Server
    }
}
EOF

# Upload files to VPS
log_info "Uploading application files to VPS..."

# Create needed directories on VPS first
sshpass -p "${VPS_PASSWORD}" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${VPS_USER}@${VPS_HOST} -p ${VPS_PORT} "mkdir -p ${REMOTE_DIR}/n8n ${REMOTE_DIR}/workflows"

# Upload individual files
scp -i "${VPS_SSH_KEY}" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -P ${VPS_PORT} \
    docker-compose.yml \
    Dockerfile \
    .env \
    Caddyfile.${DOMAIN} \
    ${VPS_USER}@${VPS_HOST}:${REMOTE_DIR}/

# Upload directories if they exist
if [ -d "n8n" ]; then
    log_info "Uploading n8n directory..."
    scp -i "${VPS_SSH_KEY}" -r -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -P ${VPS_PORT} \
        n8n/* ${VPS_USER}@${VPS_HOST}:${REMOTE_DIR}/n8n/
fi

if [ -d "workflows" ]; then
    log_info "Uploading workflows directory..."
    scp -i "${VPS_SSH_KEY}" -r -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -P ${VPS_PORT} \
        workflows/* ${VPS_USER}@${VPS_HOST}:${REMOTE_DIR}/workflows/
fi

log_info "Caddy configuration file created: Caddyfile.${DOMAIN}"
log_warn "Please manually configure Caddy using the provided file"

# Deploy application
log_info "Deploying application with Docker Compose..."
ssh -i "${VPS_SSH_KEY}" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${VPS_USER}@${VPS_HOST} -p ${VPS_PORT} << EOF
    cd ${REMOTE_DIR}

    # Stop existing containers
    docker compose down 2>/dev/null || true

    # Pull latest images
    docker compose pull

    # Start services
    docker compose up -d

    # Wait for services to be healthy
    echo "Waiting for services to start..."
    sleep 10

    # Show status
    docker compose ps

    echo ""
    echo "=========================================="
    echo "Deployment completed successfully!"
    echo "=========================================="
    echo "Services available at:"
    echo "  - n8n: https://n8n.${DOMAIN}"
    echo "  - Qdrant: https://qdrant.${DOMAIN}"
    echo "  - MinIO API: https://minio.${DOMAIN}"
    echo "  - MinIO Console: https://minio-console.${DOMAIN}"
    echo "=========================================="
EOF

log_info "=== Deployment Complete ==="
log_info "Your application is now live!"
