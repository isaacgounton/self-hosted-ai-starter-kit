# Custom n8n Dockerfile with canvas support
FROM n8nio/n8n:latest

# Install system dependencies for canvas
USER root
# Enable community repository for ffmpeg (detect Alpine version dynamically)
RUN sed -i 's/http:\/\/dl-cdn.alpinelinux.org\/alpine/http:\/\/dl-cdn.alpinelinux.org\/alpine/' /etc/apk/repositories && \
    echo "$(cat /etc/apk/repositories | head -1 | sed 's/main/community/')" >> /etc/apk/repositories && \
    apk update && \
    apk add --no-cache \
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

# Prepare n8n data dir and install node modules as non-root
USER root
RUN mkdir -p /home/node/.n8n && chown -R node:node /home/node/.n8n

USER node
WORKDIR /home/node/.n8n
RUN npm install --no-audit --no-fund canvas ffmpeg jszip axios cheerio moment nodemailer

# Run container as non-root user
USER node