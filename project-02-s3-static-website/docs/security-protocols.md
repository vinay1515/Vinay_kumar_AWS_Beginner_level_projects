# Security Protocols

- **HTTPS Enforcement:** CloudFront terminates the SSL connection at the edge. By configuring `Redirect HTTP to HTTPS`, we ensure all client traffic is encrypted in transit.
- **Public Bucket Risk:** In this simple architecture, the S3 bucket is public. A more advanced security posture involves using Origin Access Control (OAC) to keep the bucket private, restricting access solely to CloudFront.