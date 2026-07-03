# Project Overview

## Purpose
Host a real, publicly accessible website on AWS using S3 for storage and CloudFront as a global CDN — the same pattern used by startups and enterprises to serve static frontends at scale for near-zero cost.

## Learning Objectives
- Create and configure an S3 bucket for static website hosting
- Understand bucket policies and public access settings
- Deploy CloudFront as a CDN in front of S3
- Understand the difference between S3 website URL vs CloudFront URL
- Invalidate CloudFront cache after an update
- Use AWS CLI to sync files to S3

## AWS Services Used

| Service | Role |
| :--- | :--- |
| **S3** | Stores your HTML/CSS/JS files and serves them as a website |
| **CloudFront** | CDN — caches your site at 400+ edge locations globally |
| **IAM** | Bucket policy controls who can read your files |
| **AWS CLI** | Upload and sync files from your Windows machine |

## ✅ Free Tier Status
**Near-zero cost.**
- **S3:** 5 GB storage free, 20,000 GET requests/month free
- **CloudFront:** 1 TB data transfer + 10 million requests/month free for 12 months

**Cost estimate:** Best case $0.00 · Worst case ~$0.02 (if you hammer requests)