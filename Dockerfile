# Start from the latest official n8n image, which is based on Alpine Linux.
FROM n8nio/n8n:latest

# Switch to the 'root' user to get permissions to install new software.
USER root

# --- Install ALL System-Level Dependencies ---
# We add py3-selenium directly here. This is the correct "Alpine" way.
# This avoids the "externally-managed-environment" error.
RUN apk add --no-cache \
    python3 \
    py3-pip \
    chromium \
    chromium-chromedriver \
    py3-selenium

# --- Configure for Puppeteer (Node.js) ---
# These environment variables tell Puppeteer to use the system's Chromium.
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

# Install the Puppeteer library itself using npm.
RUN npm install puppeteer

# --- Final Step ---
# Switch back to the default, non-root 'node' user for better security.
USER node
