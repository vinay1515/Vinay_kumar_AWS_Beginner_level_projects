# Deployment Guide

Follow these step-by-step instructions to deploy your static website using S3 and CloudFront.

## Prerequisites: Website Files — Create These First

Before touching AWS, create your website files locally. In PowerShell:

```powershell
# Navigate to your repo
cd aws-cloud-projects
mkdir project-02-s3-static-website
cd project-02-s3-static-website
mkdir website screenshots
```

Create `website\index.html` — paste this content:
```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>My AWS Portfolio</title>
  <style>
    body { font-family: Arial, sans-serif; max-width: 800px; margin: 60px auto; padding: 0 20px; background: #f5f5f5; }
    h1   { color: #232f3e; }
    .badge { background: #ff9900; color: white; padding: 4px 12px; border-radius: 4px; font-size: 14px; }
    p    { color: #444; line-height: 1.6; }
  </style>
</head>
<body>
  <h1>☁️ My AWS Cloud Portfolio</h1>
  <span class="badge">Hosted on AWS S3 + CloudFront</span>
  <p>This static website is served from Amazon S3 and distributed globally via CloudFront CDN.</p>
  <p>Built as part of a 14-project AWS Cloud Engineering bootcamp.</p>
  <h2>Projects Completed</h2>
  <ul>
    <li>✅ Project 1 — IAM Setup & Billing Alerts</li>
    <li>✅ Project 2 — Static Website on S3 + CloudFront</li>
  </ul>
</body>
</html>
```

Create `website\error.html`:
```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <title>404 - Page Not Found</title>
  <style>
    body { font-family: Arial, sans-serif; text-align: center; margin-top: 100px; background: #f5f5f5; }
    h1   { color: #d13212; }
  </style>
</head>
<body>
  <h1>404 — Page Not Found</h1>
  <p>This page doesn't exist on my AWS portfolio site.</p>
  <a href="/">← Back to Home</a>
</body>
</html>
```

---

## 🪣 CHECKPOINT A — Create & configure the S3 bucket

### Console Steps:
1. Sign in as your IAM user → search bar → **S3** → **Create bucket**
2. Fill in: 
   - **Bucket name:** `aws-portfolio-yourname-2024` (must be globally unique — add your name and a number)
   - **Region:** `us-east-1`
   - Uncheck **"Block all public access"** → check the acknowledgement box that appears
   - Everything else: leave as default
   - Click **Create bucket**
3. Click your new bucket → **Properties** tab → scroll to **Static website hosting** → **Edit**: 
   - **Enable:** ✅
   - **Hosting type:** Host a static website
   - **Index document:** `index.html`
   - **Error document:** `error.html`
   - Click **Save changes**
4. Still in **Properties** → scroll down → copy the **Bucket website endpoint URL** (looks like `http://aws-portfolio-yourname-2024.s3-website-us-east-1.amazonaws.com`) — save it somewhere.
5. Now go to the **Permissions** tab → **Bucket policy** → **Edit** → paste this (replace `YOUR-BUCKET-NAME`):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::YOUR-BUCKET-NAME/*"
    }
  ]
}
```
Click **Save changes**.

> ✅ **Verify**: The bucket should now show an orange **Public** badge in S3.

---

## 📤 CHECKPOINT B — Upload website files via CLI

```powershell
# Set your bucket name as a variable (easier to reuse)
$BUCKET = "aws-portfolio-yourname-2024"

# Upload all files in the website folder
aws s3 sync .\website\ s3://$BUCKET/ --region us-east-1

# Expected output:
# upload: website\index.html to s3://aws-portfolio-yourname-2024/index.html
# upload: website\error.html to s3://aws-portfolio-yourname-2024/error.html
```

Verify the files are in S3:
```powershell
aws s3 ls s3://$BUCKET/
# Expected output:
# 2024-01-01 10:00:00    852 error.html
# 2024-01-01 10:00:00   1243 index.html
```

> Test the S3 website URL — paste your bucket website endpoint into a browser.
> ✅ You should see your portfolio page served over HTTP (not HTTPS yet — CloudFront fixes that).

---

## 🌐 CHECKPOINT C — Create CloudFront distribution

### Console Steps:
1. Search bar → **CloudFront** → **Create distribution**
2. **Origin settings:** 
   - **Origin domain:** click the dropdown → select your **S3 bucket website endpoint** — *important: choose the one ending in `.s3-website-us-east-1.amazonaws.com`, NOT the plain `.s3.amazonaws.com` one*
   - **Origin protocol:** HTTP only (S3 static website hosting is HTTP)
   - Leave other origin settings as default
3. **Default cache behavior:** 
   - **Viewer protocol policy:** Redirect HTTP to HTTPS
   - **Cache policy:** CachingOptimized (default)
   - Leave everything else as default
4. **Settings:** 
   - **Price class:** Use only North America and Europe (cheapest, still fine for testing)
   - **Default root object:** `index.html`
   - Leave everything else as default
5. Click **Create distribution**

⏳ *Wait 5–10 minutes — CloudFront deploys globally. Status changes from Deploying to Enabled.*

6. Once enabled, copy your **Distribution domain name** — looks like `d1abc2defg3hij.cloudfront.net`

> ✅ **Test**: Paste `https://d1abc2defg3hij.cloudfront.net` in your browser — your site loads over HTTPS with a valid SSL certificate, served from a CDN edge location near you.

---

## CLI-only alternative — create the bucket entirely via CLI

If you want to practice doing Checkpoint A purely from PowerShell:

```powershell
$BUCKET = "aws-portfolio-yourname-2024"
$REGION = "us-east-1"

# 1. Create bucket
aws s3api create-bucket `
  --bucket $BUCKET `
  --region $REGION

# 2. Disable block public access
aws s3api put-public-access-block `
  --bucket $BUCKET `
  --public-access-block-configuration `
  "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"

# 3. Enable static website hosting
aws s3api put-bucket-website `
  --bucket $BUCKET `
  --website-configuration '{
    "IndexDocument": {"Suffix": "index.html"},
    "ErrorDocument": {"Key": "error.html"}
  }'

# 4. Apply bucket policy
aws s3api put-bucket-policy `
  --bucket $BUCKET `
  --policy '{
    "Version":"2012-10-17",
    "Statement":[{
      "Sid":"PublicReadGetObject",
      "Effect":"Allow",
      "Principal":"*",
      "Action":"s3:GetObject",
      "Resource":"arn:aws:s3:::'"$BUCKET"'/*"
    }]
  }'

# 5. Verify website config
aws s3api get-bucket-website --bucket $BUCKET
```