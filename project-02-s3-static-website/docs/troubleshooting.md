# Troubleshooting

If you encounter issues during the setup, refer to the following common problems and fixes:

| Problem | Cause | Fix |
| :--- | :--- | :--- |
| **S3 URL shows 403 Forbidden** | Bucket policy not saved or block public access still on | Re-check Permissions tab — confirm Public badge is showing |
| **S3 URL shows 404** | Wrong index document name or file not uploaded | Run `aws s3 ls s3://your-bucket/` to verify files exist |
| **CloudFront shows old content after update** | Cache not invalidated | Run the `create-invalidation` command with `/*` |
| **CloudFront shows Access Denied** | Origin domain set to S3 REST endpoint instead of website endpoint | Edit distribution origin — must end in `.s3-website-us-east-1.amazonaws.com` |
| **Distribution stuck on Deploying** | Normal — global propagation takes time | Wait 10–15 min, refresh |
| **aws s3 sync throws NoCredentialsError** | CLI not configured | Run `aws configure` and re-enter your keys |