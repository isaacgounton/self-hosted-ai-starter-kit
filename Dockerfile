# Custom n8n Dockerfile with canvas and ffmpeg support
FROM n8nio/n8n:latest

# Install system dependencies for canvas and ffmpeg
USER root
RUN apk add --no-cache \
  # Build tools for compiling native modules
  build-base \
  g++ \
  make \
  python3 \
  python3-dev \
  py3-pip \
  # Canvas dependencies (Cairo graphics library)
  cairo-dev \
  pango-dev \
  jpeg-dev \
  giflib-dev \
  librsvg-dev \
  pixman-dev \
  # FFmpeg and codecs
  ffmpeg \
  ffmpeg-libs \
  # Package config
  pkgconfig

# Switch to node user and install npm packages
USER node
RUN cd /home/node/.n8n && npm install \
  canvas \
  ffmpeg \
  jszip \
  axios \
  cheerio \
  moment \
  nodemailer

# Switch back to root for any additional setup
USER root