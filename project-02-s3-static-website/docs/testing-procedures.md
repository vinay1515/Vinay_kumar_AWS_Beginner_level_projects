# Testing Procedures

Follow these procedures to test the different stages of your deployment.

## 1. Test S3 Bucket Website Endpoint (HTTP)

After completing Checkpoint B (uploading files to S3):
1. Retrieve your S3 bucket website endpoint URL (e.g., `http://aws-portfolio-yourname-2024.s3-website-us-east-1.amazonaws.com`).
2. Paste the URL into your browser.
3. **Verify:** You should see your portfolio page served over HTTP.

## 2. Test CloudFront Distribution (HTTPS)

After completing Checkpoint C (creating the CloudFront distribution):
1. Wait for the distribution status to change from `Deploying` to `Enabled` (5-10 minutes).
2. Retrieve your CloudFront Distribution domain name (e.g., `https://d1abc2defg3hij.cloudfront.net`).
3. Paste the URL into your browser.
4. **Verify:** Your site should load over HTTPS with a valid SSL certificate, served from the CDN edge location.

## 3. Test Content Update + Cache Invalidation

Make a change to your site's content:
```powershell
# Edit index.html — add Project 3 to the list
notepad .\website\index.html
# Add: <li>⏳ Project 3 — EC2 & SSH</li>
# Save the file
```

Re-sync to S3:
```powershell
aws s3 sync .\website\ s3://$BUCKET/ --region us-east-1
```

Invalidate CloudFront cache:
```powershell
$DIST_ID = "YOUR_DISTRIBUTION_ID"

aws cloudfront create-invalidation `
  --distribution-id $DIST_ID `
  --paths "/*"
```

Wait ~30 seconds and refresh your CloudFront URL.
**Verify:** Your updated site with the new list item should be live.