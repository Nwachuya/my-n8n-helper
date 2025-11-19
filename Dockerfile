FROM n8nio/n8n:latest

USER root

# Install System Dependencies
RUN apk add --no-cache \
    python3 \
    py3-pip \
    chromium \
    chromium-chromedriver

# Configure Puppeteer
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

# Install Puppeteer
RUN npm install puppeteer

# Install Selenium (Forcefully)
RUN pip3 install selenium --break-system-packages

USER node
