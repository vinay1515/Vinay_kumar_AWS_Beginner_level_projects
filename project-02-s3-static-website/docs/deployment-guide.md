# Deployment Guide

## Step 1: Create the S3 Bucket
1. Create a bucket (e.g. `my-awesome-portfolio`).
2. Uncheck "Block all public access" and acknowledge the warning.
3. Enable "Static Website Hosting" in the properties tab, setting both index and error docs to `index.html`.

## Step 2: Apply Bucket Policy
Add the following policy to the Permissions tab to allow public read access:
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::my-awesome-portfolio/*"
        }
    ]
}
```

## Step 3: Upload Files
Upload your `index.html` and any CSS/JS assets into the bucket.

## Step 4: Create CloudFront Distribution
1. Create a new distribution.
2. Under Origin Domain, select your S3 bucket's **website endpoint** (do NOT use the dropdown auto-fill which provides the REST endpoint).
3. Viewer Protocol Policy: `Redirect HTTP to HTTPS`.
4. Create Distribution (wait 3-5 minutes for it to deploy globally).
