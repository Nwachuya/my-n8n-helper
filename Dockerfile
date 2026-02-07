FROM alpine:latest AS alpine

FROM n8nio/n8n:latest

USER root

# Copy apk and its runtime dependencies from Alpine
COPY --from=alpine /sbin/apk /sbin/apk
COPY --from=alpine /etc/apk /etc/apk
COPY --from=alpine /lib/apk /lib/apk
COPY --from=alpine /usr/share/apk /usr/share/apk
COPY --from=alpine /usr/lib/libapk.so.3.0.0 /usr/lib/
COPY --from=alpine /usr/lib/libcrypto.so.3 /usr/lib/
COPY --from=alpine /usr/lib/libssl.so.3 /usr/lib/
COPY --from=alpine /usr/lib/libz.so.1 /usr/lib/

RUN apk update && apk add --no-cache \
    bash curl git zip unzip \
    build-base libffi-dev openssl-dev \
    python3 py3-pip python3-dev \
    chromium chromium-chromedriver \
    ffmpeg \
    perl-image-exiftool whois \
    imagemagick tesseract-ocr \
    py3-numpy py3-pandas \
    gcc musl-dev linux-headers \
    && rm -rf /var/cache/apk/*

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser \
    CHROME_BIN=/usr/bin/chromium-browser \
    PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1 \
    PLAYWRIGHT_BROWSERS_PATH=/usr/bin

RUN npm install --global puppeteer

RUN pip3 install --break-system-packages --no-cache-dir --upgrade pip setuptools wheel && \
    pip3 install --break-system-packages --no-cache-dir \
    playwright \
    beautifulsoup4 lxml requests httpx fake-useragent \
    trafilatura \
    instaloader gallery-dl yt-dlp \
    advertools \
    holehe phonenumbers \
    dnspython tldextract \
    pandas openpyxl xlsxwriter pdfplumber pypdf \
    textblob langdetect \
    python-dotenv validators \
    && rm -rf /root/.cache/pip /tmp/*

USER node

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:5678/healthz || exit 1

LABEL maintainer="your-email@example.com" \
      description="n8n with automation, scraping, and data processing tools" \
      version="1.0"
