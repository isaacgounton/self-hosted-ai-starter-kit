# n8n with FFmpeg and Sharp support
# Minimal Dockerfile that preserves task runners
FROM dhanushreddy29/n8n-ffmpeg:latest

# Install Sharp dependencies and build from source for Alpine
USER root
RUN apk add --no-cache vips-dev && \
    apk add --no-cache python3 make g++ pkgconfig

USER node
WORKDIR /home/node/.n8n

# Install Sharp from source for Alpine compatibility
RUN npm install --no-audit --no-fund sharp --build-from-source && \
    npm install --no-audit --no-fund axios cheerio moment nodemailer
