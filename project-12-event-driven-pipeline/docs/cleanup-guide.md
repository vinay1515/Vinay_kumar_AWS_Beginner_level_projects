
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
    <text x="50%" y="45%" dominant-baseline="middle" text-anchor="middle" class="title glow">Event-Driven Data Pipeline</text>
    <text x="50%" y="70%" dominant-baseline="middle" text-anchor="middle" class="subtitle">Infrastructure Cleanup Guide</text>
  </svg>
</div>



<div align="center" style="margin: 30px 0; padding: 15px; border: 1px solid #e1e4e8; border-radius: 8px; background-color: #f6f8fa;">
  <table style="width: 100%; text-align: center; border: none; background: transparent;">
    <tr style="border: none;">
      <td style="width: 33%; border: none;"><a href='../../project-11-infrastructure-as-code/README.md' style='font-size: 16px; text-decoration: none;'>⏪ <b>Previous: Infrastructure As Code</b></a></td>
      <td style="width: 33%; border: none;"><a href="../README.md" style="font-size: 16px; text-decoration: none;">🏠 <b>Project Home</b></a></td>
      <td style="width: 33%; border: none;"><i>(Final Project)</i></td>
    </tr>
  </table>
</div>


<br>

<div style="background-color: #fdfdfe; border-left: 4px solid #ff9900; padding: 15px; border-radius: 4px; box-shadow: 0 2px 4px rgba(0,0,0,0.05);">
  <i>The following granular documentation is designed to provide enterprise-level clarity for deploying and managing this AWS architecture. Pay close attention to the architectural specifications and step-by-step methodologies below.</i>
</div>

<br>

To prevent any unexpected charges and keep your AWS environment clean, it is essential to tear down the infrastructure once you have finished testing the Event-Driven Pipeline.

> [!WARNING]
> This process is destructive and will delete the S3 buckets, SQS queues, Lambda functions, and IAM roles associated with this project. Ensure you do not need the data before proceeding.

## 🧹 Automated Cleanup

The fastest and most reliable way to clean up the environment is to use the provided automation scripts.

### For Windows Users (PowerShell)
Navigate to the `scripts/powershell/` directory and execute:
```powershell
.\10-cleanup.ps1
```

### For Linux/Mac Users (Bash)
Navigate to the `scripts/bash/` directory and execute:
```bash
./10-cleanup.sh
```

---

## 🛠️ Manual Cleanup Steps (Console/CLI)

If you prefer to verify what is being deleted or want to clean up manually, follow these steps in order:

### 1. Delete Event Source Mapping
If you delete the queue before the mapping, Lambda might enter an error state.
```bash
aws lambda list-event-source-mappings --function-name file-processor
# Copy the UUID, then run:
aws lambda delete-event-source-mapping --uuid <UUID>
```

### 2. Delete the Lambda Function
```bash
aws lambda delete-function --function-name file-processor
```

### 3. Delete the SQS Queues
Delete both the main processing queue and the Dead Letter Queue.
```bash
aws sqs delete-queue --queue-url <MAIN_QUEUE_URL>
aws sqs delete-queue --queue-url <DLQ_URL>
```

### 4. Empty and Delete S3 Buckets
S3 buckets must be completely empty (including all versions if versioning is enabled) before they can be deleted.
```bash
# Empty buckets
aws s3 rm s3://event-pipeline-source-<ACCOUNT_ID> --recursive
aws s3 rm s3://event-pipeline-output-<ACCOUNT_ID> --recursive

# Delete buckets
aws s3api delete-bucket --bucket event-pipeline-source-<ACCOUNT_ID> --region ap-south-1
aws s3api delete-bucket --bucket event-pipeline-output-<ACCOUNT_ID> --region ap-south-1
```

### 5. Remove IAM Policies and Delete Role
Detach all managed policies, delete inline policies, and finally delete the role.
```bash
aws iam detach-role-policy --role-name lambda-file-processor-role --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
aws iam detach-role-policy --role-name lambda-file-processor-role --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole

aws iam delete-role-policy --role-name lambda-file-processor-role --policy-name s3-pipeline-access

aws iam delete-role --role-name lambda-file-processor-role
```

### 6. Delete CloudWatch Logs (Optional)
To clean up the logs generated by the Lambda function executions:
```bash
aws logs delete-log-group --log-group-name "/aws/lambda/file-processor"
```

## ✅ Final Verification

To ensure nothing was left behind, you can run:
```bash
aws lambda list-functions --query "Functions[?FunctionName=='file-processor'].FunctionName" --output text
```
If the output is completely empty, the cleanup was successful!

<br>


<div align="center" style="margin: 30px 0; padding: 15px; border: 1px solid #e1e4e8; border-radius: 8px; background-color: #f6f8fa;">
  <table style="width: 100%; text-align: center; border: none; background: transparent;">
    <tr style="border: none;">
      <td style="width: 33%; border: none;"><a href='../../project-11-infrastructure-as-code/README.md' style='font-size: 16px; text-decoration: none;'>⏪ <b>Previous: Infrastructure As Code</b></a></td>
      <td style="width: 33%; border: none;"><a href="../README.md" style="font-size: 16px; text-decoration: none;">🏠 <b>Project Home</b></a></td>
      <td style="width: 33%; border: none;"><i>(Final Project)</i></td>
    </tr>
  </table>
</div>

