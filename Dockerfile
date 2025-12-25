# n8n with FFmpeg, Python, and Canvas support
# Base image: https://github.com/RxChi1d/n8n-ffmpeg
# Docker Hub: https://hub.docker.com/r/rxchi1d/n8n-ffmpeg

FROM rxchi1d/n8n-ffmpeg:latest

# Switch to root to install system packages
USER root

# Install Python3 for Python task runner
RUN apk add --no-cache python3 py3-pip

# Install canvas dependencies
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
