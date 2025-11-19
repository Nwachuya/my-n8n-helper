# Start from the latest official n8n image, which is based on Debian Linux.
FROM n8nio/n8n:latest

# Switch to the 'root' user to get permissions to install new software.
USER root

# --- Install System-Level Dependencies for Both Selenium & Puppeteer ---
# We do this in a single RUN command to keep the Docker image smaller.
# - python3 and python3-pip: For running Python code and installing Python libraries.
# - chromium: The open-source version of the Chrome browser.
# - chromium-driver: The bridge that allows Selenium to control the Chromium browser.
# - The other packages (nss, freetype, etc.) are required by Chromium to correctly
#   render fonts and handle connections in a headless environment.
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    chromium \
    chromium-driver \
    nss \
    libatk-bridge2.0-0 \
    libgtk-3-0 \
    libasound2 \
    libxss1 \
    libxtst6 \
    && rm -rf /var/lib/apt/lists/*

# --- Configure for Puppeteer (Node.js) ---
# These environment variables tell the Puppeteer library to use the Chromium
# browser we just installed with apt-get, instead of downloading its own copy.
# This saves a lot of disk space and is the correct way to do it.
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

# Install the Puppeteer library itself using npm.
RUN npm install puppeteer

# --- Configure for Selenium (Python) ---
# Install the Selenium library using pip.
RUN pip3 install selenium

# --- Final Step ---
# Switch back to the default, non-root 'node' user for better security.
# n8n will run as this user.
USER node
