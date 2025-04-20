# -------- Stage 1: Scraper --------
FROM node:18-slim AS scraper

# Install Chromium
RUN apt-get update && apt-get install -y chromium \
    fonts-liberation libappindicator3-1 libasound2 \
    libatk-bridge2.0-0 libatk1.0-0 libcups2 libdbus-1-3 \
    libgdk-pixbuf2.0-0 libnspr4 libnss3 libx11-xcb1 \
    libxcomposite1 libxdamage1 libxrandr2 xdg-utils wget \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set environment to skip Puppeteer's Chromium download
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

# Copy and install Node files
WORKDIR /app
COPY package.json ./
RUN npm install
COPY scrape.js ./
ENV SCRAPE_URL=https://hotstar.com
RUN node scrape.js

# -------- Stage 2: Server --------
FROM python:3.10-slim

WORKDIR /app

# Copy only the scraped data and server
COPY --from=scraper /app/scraped_data.json ./
COPY server.py ./
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 5000
CMD ["python", "server.py"]

