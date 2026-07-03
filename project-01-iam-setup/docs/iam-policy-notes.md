
<div align="center">
  <svg width="800" height="150" xmlns="http://www.w3.org/2000/svg">
    <style>
      .bg { fill: url(#grad); stroke: #e1e4e8; stroke-width: 2px; rx: 12px; }
      .title { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; font-size: 28px; font-weight: 800; fill: #ffffff; }
      .subtitle { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; font-size: 16px; font-weight: 500; fill: #e1e4e8; }
      .glow { animation: pulse 3s infinite alternate; }
      @keyframes pulse {
        0% { opacity: 0.8; filter: drop-shadow(0 0 4px rgba(255,153,0,0.4)); }
        100% { opacity: 1; filter: drop-shadow(0 0 12px rgba(255,153,0,0.9)); }
      }
      @media (prefers-color-scheme: dark) {
        .bg { stroke: #30363d; }
      }
    </style>
    <defs>
      <linearGradient id="grad" x1="0%" y1="0%" x2="100%" y2="100%">
        <stop offset="0%" style="stop-color:#232f3e;stop-opacity:1" />
        <stop offset="100%" style="stop-color:#ff9900;stop-opacity:1" />
      </linearGradient>
    </defs>
    <rect width="100%" height="100%" class="bg" />
    <text x="50%" y="45%" dominant-baseline="middle" text-anchor="middle" class="title glow">IAM Setup & Security</text>
    <text x="50%" y="70%" dominant-baseline="middle" text-anchor="middle" class="subtitle">iam-policy-notes.md</text>
  </svg>
</div>



<div align="center" style="margin: 30px 0; padding: 15px; border: 1px solid #e1e4e8; border-radius: 8px; background-color: #f6f8fa;">
  <table style="width: 100%; text-align: center; border: none; background: transparent;">
    <tr style="border: none;">
      <td style="width: 33%; border: none;"><i>(First Project)</i></td>
      <td style="width: 33%; border: none;"><a href="../README.md" style="font-size: 16px; text-decoration: none;">🏠 <b>Project Home</b></a></td>
      <td style="width: 33%; border: none;"><a href='../../project-02-s3-static-website/README.md' style='font-size: 16px; text-decoration: none;'><b>Next: S3 Static Website</b> ⏩</a></td>
    </tr>
  </table>
</div>


<br>

<div style="background-color: #fdfdfe; border-left: 4px solid #ff9900; padding: 15px; border-radius: 4px; box-shadow: 0 2px 4px rgba(0,0,0,0.05);">
  <i>The following granular documentation is designed to provide enterprise-level clarity for deploying and managing this AWS architecture. Pay close attention to the architectural specifications and step-by-step methodologies below.</i>
</div>

<br>

## What is an IAM Policy?
A JSON document that defines what actions are allowed or denied,
on which resources, and under what conditions.

## Policy Structure (every policy has these 4 parts)

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":    "Allow" or "Deny",
      "Action":    "what API calls are permitted",
      "Resource":  "which AWS resources this applies to",
      "Condition": "optional - when this rule applies"
    }
  ]
}
```

## The 3 Types of Policies You'll Use Most

| Type | What it is | Example |
|---|---|---|
| AWS Managed | Pre-built by AWS, maintained by AWS | AdministratorAccess, ReadOnlyAccess |
| Customer Managed | You write and own it | Your custom S3 read-only policy |
| Inline | Attached directly to one user/role | One-off permissions, avoid these |

## Policies Created in This Project

### 1. AdministratorAccess (AWS Managed)
Attached to: admin-yourname
Effect: Allows ALL actions on ALL resources.
Use case: Your personal admin user only. Never attach this to an app or service.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "*",
      "Resource": "*"
    }
  ]
}
```
⚠️ This is the most powerful policy in AWS. Treat it like a master key.

### 2. S3 Read-Only (Mini Challenge — Customer Managed)
Attached to: s3-readonly user
Effect: Can list buckets and read objects, nothing else.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListAllMyBuckets",
        "s3:GetObject"
      ],
      "Resource": "*"
    }
  ]
}
```

## The Golden Rule: Least Privilege
Always grant the MINIMUM permissions needed to do the job.
- A Lambda function reading from S3? Give it s3:GetObject only.
- A developer deploying code? Give CodeDeploy permissions only.
- Never use AdministratorAccess for apps, services, or CI/CD pipelines.

## IAM Concepts Cheat Sheet

| Term | Meaning |
|---|---|
| User | A person. Has long-term credentials (password + access keys). |
| Group | A collection of users. Attach policies to groups, not individual users. |
| Role | An identity assumed temporarily by a service or person. No long-term keys. |
| Policy | The JSON document that defines permissions. |
| ARN | Amazon Resource Name — unique ID for every AWS resource. |
| MFA | Multi-Factor Authentication. Always enable on root + admin users. |

## ARN Format
arn:aws:SERVICE:REGION:ACCOUNT-ID:RESOURCE
Example: arn:aws:iam::123456789012:user/admin-raj
         arn:aws:s3:::my-bucket-name
         arn:aws:ec2:us-east-1:123456789012:instance/i-0abc123

## Policies I Will Add Here as Projects Progress
- Project 2: S3 bucket policy for static website hosting
- Project 3: EC2 instance profile role
- Project 5: VPC Flow Logs role
- Project 6: RDS access policy
- Project 8: Lambda execution role
- Project 9: CodePipeline service role
...and so on.

## Common Mistakes to Avoid
- ❌ Storing access keys in code or committing them to GitHub
- ❌ Using root user for day-to-day work
- ❌ Giving AdministratorAccess to Lambda functions or EC2 instances
- ❌ Creating users with no MFA for console access
- ✅ Use roles for services (EC2, Lambda) — never access keys
- ✅ Use groups to manage permissions at scale
- ✅ Review IAM Access Analyzer regularly for unused permissions

<br>


<div align="center" style="margin: 30px 0; padding: 15px; border: 1px solid #e1e4e8; border-radius: 8px; background-color: #f6f8fa;">
  <table style="width: 100%; text-align: center; border: none; background: transparent;">
    <tr style="border: none;">
      <td style="width: 33%; border: none;"><i>(First Project)</i></td>
      <td style="width: 33%; border: none;"><a href="../README.md" style="font-size: 16px; text-decoration: none;">🏠 <b>Project Home</b></a></td>
      <td style="width: 33%; border: none;"><a href='../../project-02-s3-static-website/README.md' style='font-size: 16px; text-decoration: none;'><b>Next: S3 Static Website</b> ⏩</a></td>
    </tr>
  </table>
</div>

