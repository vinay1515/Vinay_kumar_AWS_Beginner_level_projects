# Troubleshooting

| Issue | Cause | Fix |
|---|---|---|
| **AccessDenied (403)** | Missing Bucket Policy | Ensure the public read policy is applied and "Block Public Access" is turned off on the bucket. |
| **Files download instead of rendering** | Incorrect Content-Type | S3 may have set the content type to `binary/octet-stream`. Update the metadata of the `index.html` object to `text/html`. |
| **Updates not showing on the website** | CloudFront Caching | CloudFront caches objects for 24 hours by default. Create a cache invalidation for `/*` in the CloudFront console. |