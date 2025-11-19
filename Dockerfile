# Start from the latest official n8n image, which is based on Alpine Linux.
FROM n8nio/n8n:latest

# Switch to the 'root' user to get permissions to install new software.
USER root

# --- Install System-Level Dependencies for Both Selenium & Puppeteer ---
# We use 'apk' which is the package manager for Alpine Linux.
# --no-cache prevents it from storing unnecessary files, keeping the image small.
RUN apk add --no-cache \
    python3 \
    py3-pip \
    chromium \
    chromium-chromedriver

# --- Configure for Puppeteer (Node.js) ---
# These environment variables tell Puppeteer to use the system's Chromium.
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

# Install the Puppeteer library itself using npm.
RUN npm install puppeteer

# --- Configure for Selenium (Python) ---
# Install the Selenium library using pip.
RUN pip3 install selenium

# --- Final Step ---
# Switch back to the default, non-root 'node' user for better security.
USER node
