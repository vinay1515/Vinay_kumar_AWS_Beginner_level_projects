# Architecture Details

## API Gateway (REST API)
- Acts as a reverse proxy. Configured with a `/{proxy+}` greedy path and `ANY` method to forward all requests to a single Lambda function.
- Integrates via **Lambda Proxy Integration**, passing headers, query parameters, and body directly in the event object.

## AWS Lambda
- **Runtime:** Python 3.12.
- Contains the routing logic (checking `event['httpMethod']`) to perform CRUD operations.
- Attached to an IAM Execution Role granting basic execution (CloudWatch Logs) and `dynamodb:*Item` permissions.

## Amazon DynamoDB
- **Table Name:** `users`
- **Partition Key:** `userId` (String).
- **Billing Mode:** On-Demand (pay per request, no provisioned capacity limits).