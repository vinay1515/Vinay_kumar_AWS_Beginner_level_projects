# Cleanup Instructions

Run these steps when you're done testing to avoid any unexpected charges.

## 1. Disable and Delete CloudFront Distribution
You must disable the distribution first before deleting it.

**Using PowerShell:**
```powershell
$DIST_ID = "YOUR_DISTRIBUTION_ID"

aws cloudfront update-distribution `
  --id $DIST_ID `
  --if-match (aws cloudfront get-distribution-config --id $DIST_ID | ConvertFrom-Json).ETag `
  --distribution-config (aws cloudfront get-distribution-config --id $DIST_ID | ConvertFrom-Json).DistributionConfig
```
*Note: Deletion via CLI requires ETag matching which is fiddly for beginners. The easiest path is using the AWS Console.*

**Using AWS Console (Recommended):**
1. Navigate to **CloudFront** → **Distributions**
2. Select your distribution
3. Click **Disable**
4. Wait 5-10 minutes for it to fully disable
5. Click **Delete**

## 2. Empty the S3 Bucket
You must empty the bucket before deleting it.

```powershell
$BUCKET = "aws-portfolio-yourname-2024"

aws s3 rm s3://$BUCKET --recursive
```

## 3. Delete the S3 Bucket

```powershell
aws s3api delete-bucket --bucket $BUCKET --region us-east-1
```