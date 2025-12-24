# Start from the official n8n image (It is currently Debian/Ubuntu-based, not Alpine)
FROM n8nio/n8n:latest

# Switch to root to install system packages
USER root

# ----------------------------------------------------------------
# 1. SYSTEM PACKAGES (APT)
# ----------------------------------------------------------------
# Update package lists and install packages using apt
RUN apt update && apt install -y --no-install-recommends \
    # --- Basics & Build Tools ---
    bash \
    curl \
    git \
    zip \
    unzip \
    build-essential \
    libffi-dev \
    libssl-dev \
    # --- Python Environment ---
    python3 \
    python3-pip \
    # --- Browser Engine (Selenium/Puppeteer) ---
    chromium \
    chromium-driver \
    # --- Media Processing ---
    ffmpeg \
    # --- OSINT & Metadata Tools ---
    exiftool \
    whois \
    # --- OCR & Image Processing ---
    imagemagick \
    tesseract-ocr \
    # --- Data Science Acceleration (Faster than pip) ---
    python3-numpy \
    python3-pandas \
    # Clean up APT lists to keep the image small
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

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
# The --break-system-packages flag is for Debian/Ubuntu (not needed on Alpine)
# but it's safe to use to avoid potential conflicts with system Python.
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
