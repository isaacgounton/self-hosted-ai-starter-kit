# n8n with FFmpeg support
# Minimal Dockerfile - Sharp removed due to Alpine compilation issues
FROM dhanushreddy29/n8n-ffmpeg:latest

USER node
WORKDIR /home/node/.n8n

# Install working packages (no Sharp, too heavy for Alpine)
RUN npm install --no-audit --no-fund axios cheerio moment nodemailer
