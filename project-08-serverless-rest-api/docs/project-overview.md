# Project 08 Overview: Serverless REST API

## 🎯 Business Problem

Traditional server-based architectures (like EC2) present significant operational overhead. You must provision capacity for peak traffic, pay for idle resources when traffic is low, manage OS patching, configure auto-scaling rules, and handle load balancing. For highly variable workloads, bursty traffic, or APIs with unpredictable usage, paying for always-on servers is economically inefficient and operationally burdensome.

## 🚀 Solution

Build a fully serverless REST API from scratch using AWS API Gateway, AWS Lambda, and Amazon DynamoDB. 

In this architecture:
- **No servers to manage:** AWS handles all underlying infrastructure.
- **Scales to zero:** When there is no traffic, you pay exactly $0.00.
- **Instant elasticity:** Handles thousands of concurrent requests automatically.
- **High Availability:** Resources are inherently distributed across multiple Availability Zones.

This is the most in-demand intermediate AWS skill and a foundational pattern for modern cloud-native development.

## 🏆 Learning Objectives

By completing this project, you will learn how to:
1. **Understand the serverless computing model** and its economic benefits
2. **Write and deploy AWS Lambda functions** in Python using the `boto3` SDK
3. **Create a REST API using API Gateway** with proxy integration
4. **Use DynamoDB** as a serverless NoSQL database for ultra-low latency data access
5. **Implement Least Privilege IAM Roles** to connect Lambda securely to DynamoDB
6. **Test API endpoints** using curl, Postman, and PowerShell
7. **Monitor serverless applications** using CloudWatch Logs and Metrics

## 🛠️ AWS Services Used

| Service | Role in Architecture |
|:---|:---|
| **API Gateway** | Entry point; routes HTTP requests to Lambda, handles CORS |
| **AWS Lambda** | Compute layer; executes Python business logic on-demand |
| **Amazon DynamoDB** | Data layer; fully managed NoSQL database for storing user records |
| **IAM** | Security layer; grants Lambda execution permissions |
| **CloudWatch Logs** | Observability; stores function execution output and stack traces |

## ⚖️ Serverless vs Traditional Architecture

| Aspect | Traditional (EC2) | Serverless (Lambda) |
|:---|:---|:---|
| **Server management** | You manage OS, patches, networking | AWS manages everything |
| **Scaling** | Manual ASG configuration, slow boot times | Automatic — scales per request |
| **Cost model** | Pay per hour (running or idle) | Pay per 1ms of execution time |
| **Cold starts** | None (always warm) | ~100ms–1s on first invocation |
| **Max execution** | Unlimited | 15 minutes per invocation |
| **Concurrency** | Limited by instance count | Up to 1,000 concurrent (default) |
| **Use case** | Long-running workloads, legacy apps | Event-driven, APIs, microservices |

## ✅ Free Tier Status

| Resource | Free Tier | Notes |
|:---|:---|:---|
| **Lambda Requests** | 1M requests/month | Permanent Free Tier |
| **Lambda Compute** | 400,000 GB-seconds/month | Permanent Free Tier |
| **API Gateway** | 1M API calls/month | Free for 12 months |
| **DynamoDB** | 25 GB storage, 25 WCU, 25 RCU | Permanent Free Tier |
| **CloudWatch Logs** | 5 GB ingestion/month | Permanent Free Tier |

> [!TIP]
> This entire architecture costs **$0.00** to run under normal testing conditions. All core services fall within the permanent AWS Free Tier.

## 🔗 Related Projects
- **Project 01**: Foundational IAM knowledge used here for Lambda execution roles
- **Project 12**: Explores event-driven serverless patterns using SQS and S3 triggers