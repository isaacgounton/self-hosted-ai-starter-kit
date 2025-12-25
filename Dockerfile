# n8n with FFmpeg support
# Base image: dhanushreddy29/n8n-ffmpeg (includes FFmpeg)
# Docker Hub: https://hub.docker.com/r/dhanushreddy29/n8n-ffmpeg
FROM dhanushreddy29/n8n-ffmpeg:latest

# Canvas removed - requires heavy compilation, can be added later if needed
# For image manipulation, consider external services or cloud APIs

# Prepare n8n data directory
USER root
RUN mkdir -p /home/node/.n8n && chown -R node:node /home/node/.n8n

# Run container as non-root user
USER node
WORKDIR /home/node/.n8n
