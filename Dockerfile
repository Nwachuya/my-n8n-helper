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
    # Browser automation (needed by Playwright/Crawl4AI)
    chromium \
    && rm -rf /var/cache/apk/*

# ============================================
# Step 3: Install n8n Community Nodes
# ============================================
RUN mkdir -p /home/node/.n8n/nodes && \
    cd /home/node/.n8n/nodes && \
    npm init -y && \
    npm install n8n-nodes-nca-toolkit-v2 && \
    chown -R node:node /home/node/.n8n

# ============================================
# Step 4: Install Python Packages
# ============================================
RUN pip3 install --break-system-packages --no-cache-dir --upgrade pip setuptools wheel && \
    pip3 install --break-system-packages --no-cache-dir --upgrade \
    # Web scraping & parsing
    beautifulsoup4 lxml requests httpx trafilatura \
    # SEO & marketing
    advertools \
    # OSINT & research
    phonenumbers maigret holehe \
    # Data processing
    pandas openpyxl xlsxwriter \
    # PDF processing
    pdfplumber pypdf \
    # Text processing
    textblob langdetect \
    # Utilities
    python-dotenv validators \
    # Web crawling
    crawl4ai \
    && rm -rf /root/.cache/pip /tmp/*

# ============================================
# Step 5: Setup Crawl4AI (install Playwright browsers)
# ============================================
RUN playwright install --with-deps chromium

# ============================================
# Step 6: Create directories for shared files
# ============================================
RUN mkdir -p /data/shared-files && \
    chown -R node:node /data/shared-files

# ============================================
# Step 7: Health Check
# ============================================
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:5678/healthz || exit 1

# ============================================
# Metadata
# ============================================
LABEL maintainer="n8n-automation" \
      description="n8n with web scraping, media processing, OCR, Crawl4AI & NCA Toolkit" \
      version="3.0-clean"

USER node
