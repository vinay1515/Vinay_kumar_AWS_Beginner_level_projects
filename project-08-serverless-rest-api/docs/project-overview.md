# Project Overview: Serverless REST API

## 🎯 Purpose
Build a fully serverless REST API from scratch — no servers to manage, no EC2 to patch, scales automatically from zero to millions of requests. This is the most in-demand intermediate AWS skill and appears in virtually every Solutions Architect interview.

## 🎓 Learning Objectives
- Understand the serverless computing model
- Write and deploy AWS Lambda functions in Python
- Create a REST API using API Gateway
- Use DynamoDB as a serverless NoSQL database
- Connect Lambda to DynamoDB with IAM roles
- Test API endpoints with real HTTP requests
- Understand Lambda execution roles and least privilege
- Monitor serverless apps with CloudWatch Logs

## ⚖️ Serverless vs Traditional Architecture
| Aspect | Traditional (EC2) | Serverless (Lambda) |
|:---|:---|:---|
| **Server management** | You manage OS, patches | AWS manages everything |
| **Scaling** | Manual ASG configuration | Automatic — instant |
| **Cost model** | Pay per hour (running or idle) | Pay per request (zero cost at zero traffic) |
| **Cold starts** | None (always warm) | ~100ms–1s on first invocation |
| **Max execution** | Unlimited | 15 minutes per invocation |
| **Concurrency** | Limited by instance count | Up to 1,000 concurrent (default) |
| **Use case** | Long-running workloads | Event-driven, short-burst APIs |

## ✅ Free Tier Status
| Resource | Free Tier | Notes |
|:---|:---|:---|
| **Lambda** | 1M requests/month free forever | Not just 12 months |
| **Lambda compute** | 400,000 GB-seconds/month free forever | More than enough |
| **API Gateway** | 1M API calls/month free (12 months) | Fine for this project |
| **DynamoDB** | 25 GB storage + 25 WCU + 25 RCU free forever | Very generous |

> Cost estimate: $0.00 — all three services are within permanent free tier.