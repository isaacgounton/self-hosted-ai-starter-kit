# n8n with FFmpeg and Sharp support
# Base image: dhanushreddy29/n8n-ffmpeg (includes FFmpeg)
# Docker Hub: https://hub.docker.com/r/dhanushreddy29/n8n-ffmpeg
FROM dhanushreddy29/n8n-ffmpeg:latest

# Sharp is a canvas alternative - uses precompiled binaries, no compilation needed
# For image manipulation: https://github.com/lovell/sharp

# Prepare n8n data directory
USER root
RUN mkdir -p /home/node/.n8n && chown -R node:node /home/node/.n8n

# Install Sharp dependencies (much lighter than canvas)
RUN apk add --no-cache vips-dev

# Run container as non-root user
USER node
WORKDIR /home/node/.n8n

# Install Sharp and other npm packages (no compilation, uses prebuilt binaries)
RUN npm install --no-audit --no-fund sharp axios cheerio moment nodemailer
