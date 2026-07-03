# Troubleshooting

| Issue | Cause | Fix |
|---|---|---|
| **502 Bad Gateway** | Lambda Response Format | When using Lambda Proxy Integration, your Lambda must return a JSON object with `statusCode` (int) and `body` (stringified JSON). |
| **Missing Authentication Token** | URL Path | The URL must include the stage name (e.g. `/prod/users`). Check your URL path. |
| **Internal Server Error (500)** | IAM Permissions / Code Error | Check CloudWatch Logs for the Lambda function. It likely lacks `dynamodb` permissions or has a syntax error in the Python code. |