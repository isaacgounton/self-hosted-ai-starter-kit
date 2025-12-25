# n8n with FFmpeg support
# This Dockerfile uses a pre-built image that includes FFmpeg
# Source: https://github.com/RxChi1d/n8n-ffmpeg
# Docker Hub: https://hub.docker.com/r/rxchi1d/n8n-ffmpeg

FROM rxchi1d/n8n-ffmpeg:latest

# The image already includes FFmpeg and is based on official n8n
# No additional packages needed

USER node
WORKDIR /home/node/.n8n

# Install additional npm packages for canvas support
RUN npm install --no-audit --no-fund canvas jszip axios cheerio moment nodemailer

USER node
