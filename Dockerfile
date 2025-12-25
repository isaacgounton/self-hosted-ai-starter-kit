# n8n with Canvas support
# Based on official n8n image
# FFmpeg removed due to Alpine compatibility issues - can be added later via external service
FROM docker.n8n.io/n8nio/n8n:latest

# Switch to root to install system packages
USER root

# Install canvas build dependencies
RUN apk add --no-cache \
  build-base \
  g++ \
  cairo-dev \
  pango-dev \
  giflib-dev \
  libjpeg-turbo-dev \
  librsvg-dev \
  pixman-dev \
  pkgconfig

# Prepare n8n data directory
RUN mkdir -p /home/node/.n8n && chown -R node:node /home/node/.n8n

# Switch to node user and install npm packages
USER node
WORKDIR /home/node/.n8n

# Install canvas and other npm packages
RUN npm install --no-audit --no-fund canvas jszip axios cheerio moment nodemailer

# Run container as non-root user
USER node
