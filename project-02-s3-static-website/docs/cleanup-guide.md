# Cleanup Guide

To avoid unexpected charges (though this project is likely in the free tier), delete the resources in this order:

1. **Disable CloudFront Distribution:** Go to CloudFront, select the distribution, and click Disable. This takes 3-5 minutes.
2. **Delete CloudFront Distribution:** Once disabled, the Delete button will become active.
3. **Empty S3 Bucket:** Go to S3, select the bucket, click Empty, and confirm.
4. **Delete S3 Bucket:** Select the bucket, click Delete, and confirm.