# Cleanup Guide

To ensure you incur absolutely zero charges:

1. **Delete API Gateway:** Navigate to API Gateway, select your API, and click Delete.
2. **Delete Lambda Function:** Navigate to Lambda, select your function, and click Delete.
3. **Delete DynamoDB Table:** Navigate to DynamoDB, select the `users` table, and click Delete.
4. **Delete IAM Role:** Navigate to IAM > Roles and delete the execution role you created for Lambda.