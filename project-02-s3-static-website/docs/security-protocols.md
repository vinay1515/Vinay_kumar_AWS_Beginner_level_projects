# Security Protocols

For this beginner project, we are deliberately making the S3 bucket public to understand how static website hosting works. In a production environment with sensitive data, you would restrict access using CloudFront Origin Access Control (OAC).

## IAM Bucket Policy
To allow public read access for your static website, the following bucket policy must be applied:

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

## Public Access Settings
In order to apply the above bucket policy, you must first disable **Block all public access** on the S3 bucket.

## CloudFront Security
- **Viewer Protocol Policy**: Set to `Redirect HTTP to HTTPS` to ensure all user traffic to the CDN is encrypted.
- **Origin Protocol**: Set to `HTTP only` (since S3 static website hosting only serves over HTTP).