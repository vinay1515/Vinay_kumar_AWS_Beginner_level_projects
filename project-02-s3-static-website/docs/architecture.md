# Architecture Details

## Amazon S3 (The Origin)
- Configured to host static assets (`index.html`, `style.css`, etc.).
- A bucket policy is applied allowing `s3:GetObject` publicly so CloudFront can fetch the assets.
- `index.html` is configured as both the Default Root Object and the Error Document.

## Amazon CloudFront (The CDN)
- Distributed across 400+ Edge Locations worldwide.
- Configured with a `ViewerProtocolPolicy` of `redirect-to-https`.
- Points to the S3 Bucket's website endpoint (not the REST endpoint) to allow S3 to natively handle index document resolution.
