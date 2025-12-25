# n8n with FFmpeg and Canvas support
# Base image: dhanushreddy29/n8n-ffmpeg (includes FFmpeg)
# Docker Hub: https://hub.docker.com/r/dhanushreddy29/n8n-ffmpeg
FROM dhanushreddy29/n8n-ffmpeg:latest

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
