FROM alpine:latest AS alpine
FROM n8nio/n8n:latest

USER root

# ============================================
# Step 1: Restore APK Package Manager
# ============================================
COPY --from=alpine /sbin/apk /sbin/apk
COPY --from=alpine /etc/apk /etc/apk
COPY --from=alpine /lib/apk /lib/apk
COPY --from=alpine /usr/share/apk /usr/share/apk
COPY --from=alpine /usr/lib/libapk.so.3.0.0 /usr/lib/
COPY --from=alpine /usr/lib/libcrypto.so.3 /usr/lib/
COPY --from=alpine /usr/lib/libssl.so.3 /usr/lib/
COPY --from=alpine /usr/lib/libz.so.1 /usr/lib/

# ============================================
# Step 2: Install System Packages
# ============================================
RUN apk update && apk add --no-cache \
    # Core build tools
    build-base libffi-dev openssl-dev \
    # Python runtime
    python3 py3-pip python3-dev \
    # Media processing
    ffmpeg \
    # Metadata & utilities
    perl-image-exiftool whois \
    # Image processing
    imagemagick tesseract-ocr \
    # Browser automation
    chromium chromium-chromedriver \
    # Node.js (latest - required for yt-dlp JavaScript runtime)
    nodejs-current npm \
    && rm -rf /var/cache/apk/*

# ============================================
# Step 3: Configure Browser Environment
# ============================================
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser \
    CHROME_BIN=/usr/bin/chromium-browser

# ============================================
# Step 4: Install Node.js Packages
# ============================================
RUN npm install --global puppeteer

# ============================================
# Step 5: Install Python Packages (Always Latest)
# Using --upgrade flag ensures latest versions
# ============================================
RUN pip3 install --break-system-packages --no-cache-dir --upgrade pip setuptools wheel && \
    pip3 install --break-system-packages --no-cache-dir --upgrade \
    # Web scraping & parsing
    beautifulsoup4 lxml requests httpx fake-useragent trafilatura \
    # Media downloaders (always fetch latest)
    yt-dlp gallery-dl instaloader \
    # SEO & marketing
    advertools \
    # OSINT & research
    holehe phonenumbers \
    # Data processing
    pandas openpyxl xlsxwriter \
    # PDF processing  
    pdfplumber pypdf \
    # Text processing
    textblob langdetect \
    # Utilities
    python-dotenv validators \
    # Browser automation
    selenium \
    && rm -rf /root/.cache/pip /tmp/*

# ============================================
# Step 6: Create cookies directory for yt-dlp
# ============================================
RUN mkdir -p /home/node/.cookies && \
    chown -R node:node /home/node/.cookies

# ============================================
# Step 7: Health Check
# ============================================
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:5678/healthz || exit 1

# ============================================
# Metadata
# ============================================
LABEL maintainer="n8n-automation" \
      description="n8n with web scraping, media downloads, browser automation & OSINT tools" \
      version="2.0-streamlined" \
      nodejs.version="current" \
      yt-dlp.version="latest"

USER node
