# Start from the official n8n image (Alpine Linux based)
FROM n8nio/n8n:latest

# Switch to root to install system packages
USER root

# ----------------------------------------------------------------
# 1. SYSTEM PACKAGES (APK)
# ----------------------------------------------------------------
RUN apk add --no-cache \
    # --- Basics & Build Tools ---
    bash \
    curl \
    git \
    zip \
    unzip \
    build-base \
    libffi-dev \
    openssl-dev \
    # --- Python Environment ---
    python3 \
    py3-pip \
    # --- Browser Engine (Selenium/Puppeteer) ---
    chromium \
    chromium-chromedriver \
    # --- Media Processing ---
    ffmpeg \
    # --- OSINT & Metadata Tools ---
    exiftool \
    whois \
    # --- OCR & Image Processing ---
    imagemagick \
    tesseract-ocr \
    # --- Data Science Acceleration (Faster than pip) ---
    py3-numpy \
    py3-pandas

# ----------------------------------------------------------------
# 2. NODE.JS CONFIGURATION
# ----------------------------------------------------------------
# Tell Puppeteer to use the installed Chromium instead of downloading its own
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

RUN npm install puppeteer

# ----------------------------------------------------------------
# 3. PYTHON LIBRARIES (PIP)
# ----------------------------------------------------------------
# We use --break-system-packages to bypass Alpine's safety check
RUN pip3 install --break-system-packages \
    # --- Browser Automation & Scraping ---
    selenium \
    beautifulsoup4 \
    requests \
    fake-useragent \
    # --- Social Media Extraction ---
    instaloader \
    gallery-dl \
    # --- Digital Marketing & SEO ---
    advertools \
    trafilatura \
    googlesearch-python \
    # --- Email Finding & Verification ---
    holehe \
    email-scraper \
    validate_email_address \
    # --- OSINT & Network Recon ---
    phonenumbers \
    dnspython \
    tldextract \
    # --- Media Downloading ---
    yt-dlp \
    # --- Data & File Processing ---
    pandas \
    openpyxl \
    pdfplumber \
    # --- NLP & Language Detection ---
    textblob \
    langdetect \
    pypinyin

# ----------------------------------------------------------------
# 4. FINALIZE
# ----------------------------------------------------------------
# Switch back to the default n8n user
USER node
