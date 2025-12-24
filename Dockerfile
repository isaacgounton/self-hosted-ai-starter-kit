# Custom n8n Dockerfile with canvas support
FROM n8nio/n8n:latest

# Install system dependencies for canvas
USER root
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

# Switch back to node user and install canvas
USER node
RUN cd /home/node/.n8n && npm install canvas ffmpeg jszip axios cheerio moment nodemailer

# Switch back to root for any additional setup if needed
USER root