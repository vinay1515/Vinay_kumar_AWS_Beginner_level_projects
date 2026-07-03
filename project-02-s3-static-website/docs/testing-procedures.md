# Testing Procedures

1. Open a browser and navigate to your CloudFront distribution domain name (e.g., `d1234abcd.cloudfront.net`).
2. Verify the webpage loads successfully.
3. Explicitly type `http://d1234abcd.cloudfront.net` in the URL bar.
4. Verify that it automatically redirects to `https://d1234abcd.cloudfront.net`.
5. Update your `index.html` locally, sync it to S3, and perform a Cache Invalidation. Verify the new content appears in the browser.