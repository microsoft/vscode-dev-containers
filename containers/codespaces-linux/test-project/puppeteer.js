const puppeteer = require('puppeteer');
const fs = require('fs');
const { exit } = require('process');

(async () => {
    puppeteer.defaultArgs({
        "args": ["--no-sandbox"]
    })
    const browser = await puppeteer.launch();
    const page = await browser.newPage();
    await page.goto('https://example.com');
    await page.screenshot({path: 'example.png'});

    await browser.close();

    if(fs.existsSync('example.png')) {
        console.log('example.png found')
        exit(0);
    } else {
        console.error('example.png not found!');
        exit(1);
    }

})();