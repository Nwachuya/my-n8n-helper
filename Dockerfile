# Start from the latest official n8n image (Alpine Linux based)
FROM n8nio/n8n:latest

# Switch to root to install packages
USER root

# 1. Install System Dependencies (Chromium, Python, pip)
# We do NOT install 'py3-selenium' here because it doesn't exist in this repo.
RUN apk add --no-cache \
    python3 \
    py3-pip \
    chromium \
    chromium-chromedriver

# 2. Configure Puppeteer to use the installed Chromium
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

# 3. Install Puppeteer via npm
RUN npm install puppeteer

# 4. Install Selenium via pip
# We use --break-system-packages to bypass the "externally managed environment" error.
RUN pip3 install selenium --break-system-packages

# Switch back to the default user
USER node
