// scrape.js

const puppeteer = require('puppeteer');
const fs = require('fs');

const url = process.env.SCRAPE_URL || 'https://hotstar.com'; // Get URL from environment variable

(async () => {
  const browser = await puppeteer.launch({
    headless: true, // Run in headless mode (no UI)
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });

  const page = await browser.newPage();
  await page.goto(url); // Go to the URL

  const data = await page.evaluate(() => {
    return {
      title: document.title,
      heading: document.querySelector('h1')?.innerText || 'No <h1> found'
    };
  });

  await browser.close();

  fs.writeFileSync('scraped_data.json', JSON.stringify(data, null, 2));
  console.log('✅ Scraped data saved to scraped_data.json');
})();

