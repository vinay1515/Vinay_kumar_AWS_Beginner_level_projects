# Troubleshooting Guide

This guide covers common issues, their root causes, and step-by-step resolution procedures for the Serverless REST API architecture.

## 1. Lambda AccessDenied on DynamoDB

**Symptom:** Lambda function returns `AccessDeniedException` when attempting to read/write DynamoDB.

**Cause:** The IAM execution role has not fully propagated, or the inline policy is missing the required DynamoDB actions.

**Fix:**
1. Wait 10–15 seconds after creating the IAM role before deploying Lambda (IAM propagation delay).
2. Verify the role has the correct inline policy:
   ```bash
   aws iam get-role-policy --role-name lambda-users-api-role --policy-name dynamodb-users-access
   ```
3. Ensure the policy grants `dynamodb:PutItem`, `dynamodb:GetItem`, `dynamodb:Scan`, `dynamodb:DeleteItem`, and `dynamodb:UpdateItem` on the correct table ARN.
4. Redeploy the Lambda function to pick up the updated role:
   ```bash
   aws lambda update-function-configuration --function-name users-api \
     --role "arn:aws:iam::ACCOUNT_ID:role/lambda-users-api-role"
   ```

## 2. API Gateway Returns 502 Bad Gateway

**Symptom:** API calls return `{"message": "Internal server error"}` with HTTP status 502.

**Cause:** The Lambda function is crashing before returning a valid response. Common reasons:
- Wrong handler name in Lambda configuration
- Python syntax error or import failure
- Missing environment variable

**Fix:**
1. Check CloudWatch Logs for the Lambda function:
   ```bash
   aws logs tail /aws/lambda/users-api --since 5m
   ```
2. Verify the handler is set correctly:
   ```bash
   aws lambda get-function-configuration --function-name users-api \
     --query "Handler" --output text
   # Expected: lambda_function.lambda_handler
   ```
3. If the handler is wrong, update it:
   ```bash
   aws lambda update-function-configuration --function-name users-api \
     --handler lambda_function.lambda_handler
   ```

## 3. API Returns `{"message": "Internal server error"}`

**Symptom:** API calls succeed (HTTP 200 from API Gateway perspective) but the response body contains an error message.

**Cause:** Lambda threw an unhandled Python exception. The function executed but returned an error response.

**Fix:**
1. Open CloudWatch Logs in the console: **CloudWatch** → **Log Groups** → `/aws/lambda/users-api`
2. Find the most recent log stream and look for the Python stack trace
3. Common issues:
   - `KeyError` — Missing required field in request body
   - `ClientError` — DynamoDB table name mismatch
   - `TypeError` — Incorrect data type in JSON payload

## 4. API Returns 404 for Valid Routes

**Symptom:** Hitting a valid endpoint like `POST /users` returns `{"message": "Missing Authentication Token"}` or 404.

**Cause:** Lambda Proxy Integration is not enabled on the API Gateway method.

**Fix:**
1. In the API Gateway console, navigate to your API → Resources → Select the method
2. Click **Integration Request**
3. Ensure **Use Lambda Proxy Integration** is checked ✅
4. If you change this, you must **redeploy** the API to the stage:
   ```bash
   aws apigateway create-deployment --rest-api-id <API_ID> --stage-name dev
   ```

## 5. `Invoke-RestMethod` SSL Error on Windows

**Symptom:** PowerShell `Invoke-RestMethod` throws SSL/TLS connection errors when hitting the API Gateway endpoint.

**Cause:** Windows PowerShell (5.x) may have TLS configuration issues with certain endpoints.

**Fix:**
- Add the `-SkipCertificateCheck` flag (PowerShell 7+):
  ```powershell
  Invoke-RestMethod -Uri $ApiUrl -Method POST -Body $Body -SkipCertificateCheck
  ```
- Or force TLS 1.2 before the call (PowerShell 5.x):
  ```powershell
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  ```

## 6. DynamoDB Table Already Exists

**Symptom:** `aws dynamodb create-table` returns `ResourceInUseException: Table already exists`.

**Cause:** A previous run was not fully cleaned up, or the table name collides.

**Fix:**
```bash
# Delete the existing table
aws dynamodb delete-table --table-name users

# Wait for deletion to complete
aws dynamodb wait table-not-exists --table-name users

# Recreate the table
# (run the create-dynamodb script again)
```

## 7. Lambda Package/Deployment Error

**Symptom:** `aws lambda create-function` fails with "Could not unzip uploaded file" or similar packaging error.

**Cause:** The ZIP file was created incorrectly or the `fileb://` prefix is missing.

**Fix:**
1. Ensure you use the `fileb://` prefix for binary file uploads:
   ```bash
   aws lambda create-function --function-name users-api \
     --zip-file fileb://function.zip \
     --handler lambda_function.lambda_handler \
     --runtime python3.12 \
     --role $ROLE_ARN
   ```
2. Ensure the ZIP contains the `.py` file at the root (not in a subdirectory):
   ```bash
   # Correct: zip at file level
   cd lambda && zip ../function.zip lambda_function.py

   # Wrong: zip includes directory structure
   zip function.zip lambda/lambda_function.py
   ```

## 📋 Quick Reference Table

| Problem | Cause | Quick Fix |
|:---|:---|:---|
| Lambda AccessDenied on DynamoDB | IAM role not propagated | Wait 10 seconds after creating role then redeploy |
| API Gateway returns 502 Bad Gateway | Lambda crash or wrong handler name | Check CloudWatch Logs for Python error; verify handler is `lambda_function.lambda_handler` |
| `{"message": "Internal server error"}` | Lambda threw exception | Check `/aws/lambda/users-api` CloudWatch logs for stack trace |
| API returns 404 for valid routes | Lambda proxy integration not enabled | Edit method integration → ensure Use Lambda Proxy Integration is checked |
| Invoke-RestMethod SSL error | TLS issue on Windows | Add `-SkipCertificateCheck` flag to the command |
| DynamoDB table already exists | Previous run not cleaned up | `aws dynamodb delete-table --table-name users` then recreate |
| Lambda package error | Wrong zip path | Ensure `fileb://` prefix and correct path to zip file |

## 🔍 Debug Commands

```bash
# Check Lambda function configuration
aws lambda get-function-configuration --function-name users-api

# Tail Lambda logs in real-time
aws logs tail /aws/lambda/users-api --follow

# List API Gateway resources and methods
aws apigateway get-resources --rest-api-id <API_ID>

# Describe DynamoDB table
aws dynamodb describe-table --table-name users

# Test Lambda function directly (bypassing API Gateway)
aws lambda invoke --function-name users-api \
  --payload '{"httpMethod":"GET","path":"/users","pathParameters":null}' \
  response.json && cat response.json
```