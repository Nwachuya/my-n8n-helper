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
    build-base libffi-dev openssl-dev \
    python3 py3-pip python3-dev \
    ffmpeg \
    perl-image-exiftool whois \
    imagemagick tesseract-ocr \
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
    beautifulsoup4 lxml requests httpx trafilatura \
    advertools \
    phonenumbers maigret holehe \
    pandas openpyxl xlsxwriter \
    pdfplumber pypdf \
    textblob langdetect \
    python-dotenv validators \
    && rm -rf /root/.cache/pip /tmp/*

# ============================================
# Step 5: Create shared files directory
# ============================================
RUN mkdir -p /data/shared-files && \
    chown -R node:node /data/shared-files

# ============================================
# Step 6: Health Check
# ============================================
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:5678/healthz || exit 1

LABEL maintainer="n8n-automation" \
      description="n8n with media processing, OCR, OSINT & NCA Toolkit" \
      version="3.0"

USER node
