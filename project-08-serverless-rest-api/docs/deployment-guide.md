# Deployment Guide

## Step 1: Create DynamoDB Table
1. Navigate to DynamoDB. Create table `users`.
2. Partition key: `userId` (String). Settings: On-Demand.

## Step 2: Create IAM Role for Lambda
1. Create a new Role for Lambda.
2. Attach `AWSLambdaBasicExecutionRole`.
3. Create an inline policy allowing `dynamodb:PutItem`, `GetItem`, `Scan`, `DeleteItem` on the ARN of your `users` table.

## Step 3: Create Lambda Function
1. Create a function `users-api` using Python 3.12. Attach the IAM role from Step 2.
2. Paste the Python backend code. Deploy.

## Step 4: Create API Gateway
1. Navigate to API Gateway > REST API > Build.
2. Create Resource `users`. Create Method `ANY`.
3. Integration Type: Lambda Function. **Check "Use Lambda Proxy integration"**.
4. Deploy API to a new stage called `prod`. Copy the Invoke URL.