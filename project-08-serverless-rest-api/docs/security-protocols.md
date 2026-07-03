# Security Protocols

- **IAM Least Privilege:** The Lambda function is ONLY allowed to access the specific DynamoDB table created for this project. If the code is compromised, the blast radius is strictly contained.
- **Throttling & Quotas:** API Gateway natively supports throttling (e.g., max 10,000 requests per second) and API Keys to prevent Denial of Wallet (DoW) attacks on your serverless architecture.
- **CORS:** The Lambda function returns appropriate `Access-Control-Allow-Origin` headers, allowing frontend applications to interact securely.