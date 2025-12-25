# n8n with FFmpeg and Canvas support
# Based on official n8n image
FROM docker.n8n.io/n8nio/n8n:latest

# Switch to root to install system packages
USER root

# Install FFmpeg and canvas build dependencies
RUN apk update && \
    apk add --no-cache \
  ffmpeg \
  build-base \
  g++ \
  cairo-dev \
  pango-dev \
  giflib-dev \
  libjpeg-turbo-dev \
  librsvg-dev \
  pixman-dev \
  pkgconfig && \
    rm -rf /var/cache/apk/*

# Prepare n8n data directory
RUN mkdir -p /home/node/.n8n && chown -R node:node /home/node/.n8n

# Switch to node user and install npm packages
USER node
WORKDIR /home/node/.n8n

# Install canvas and other npm packages
RUN npm install --no-audit --no-fund canvas jszip axios cheerio moment nodemailer

# Run container as non-root user
USER node
