# Troubleshooting Guide

| Problem | Cause | Fix |
|:---|:---|:---|
| **Lambda AccessDenied on DynamoDB** | IAM role not propagated | Wait 10 seconds after creating role then redeploy |
| **API Gateway returns 502 Bad Gateway** | Lambda crash or wrong handler name | Check CloudWatch Logs for Python error; verify handler is `lambda_function.lambda_handler` |
| **`{"message": "Internal server error"}`** | Lambda threw exception | Check `/aws/lambda/users-api` CloudWatch logs for stack trace |
| **API returns 404 for valid routes** | Lambda proxy integration not enabled | Edit method integration → ensure Use Lambda Proxy Integration is checked |
| **Invoke-RestMethod SSL error** | TLS issue on Windows | Add `-SkipCertificateCheck` flag to the command |
| **DynamoDB table already exists** | Previous run not cleaned up | `aws dynamodb delete-table --table-name users` then recreate |
| **Lambda package error** | Wrong zip path | Ensure `fileb://` prefix and correct path to zip file |