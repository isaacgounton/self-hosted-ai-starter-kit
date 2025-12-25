# Custom n8n Dockerfile with canvas and ffmpeg support
# Use the official n8n registry
FROM docker.n8n.io/n8nio/n8n:latest

# Switch to root to install system packages
USER root

# Install system dependencies for canvas and ffmpeg
RUN apk add --no-cache \
  build-base \
  g++ \
  cairo-dev \
  pango-dev \
  giflib-dev \
  libjpeg-turbo-dev \
  librsvg-dev \
  python3 \
  make \
  pixman-dev \
  pkgconfig \
  ffmpeg

# Prepare n8n data directory
RUN mkdir -p /home/node/.n8n && chown -R node:node /home/node/.n8n

# Switch to node user and install npm packages
USER node
WORKDIR /home/node/.n8n
RUN npm install --no-audit --no-fund canvas ffmpeg jszip axios cheerio moment nodemailer

# Run container as non-root user
USER node
