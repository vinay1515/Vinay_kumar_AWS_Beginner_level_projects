
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
    <text x="50%" y="70%" dominant-baseline="middle" text-anchor="middle" class="subtitle">Step-by-Step Deployment Guide</text>
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

The deployment of this pipeline has been fully automated using scripts, but this guide explains the underlying steps taken to provision the infrastructure.

## 🛠️ Prerequisites
- AWS Account with Admin privileges.
- AWS CLI v2 installed and configured (`aws configure`).
- Region: `ap-south-1` (Mumbai) selected.

## 🚀 Step-by-Step Provisioning

### 1. Provision S3 Buckets
We create two globally unique S3 buckets: one for the source and one for the output. We enforce Block Public Access on both to maintain security.

### 2. Provision SQS Queues
We first create the **Dead Letter Queue (DLQ)**, as its ARN is required to configure the **Main Queue**. 
We apply an SQS Resource Policy to the Main Queue to explicitly allow the Source S3 Bucket to `sqs:SendMessage`.

### 3. Wire S3 to SQS
We configure the Source S3 Bucket's Event Notification rules. 
- **Filter Prefix:** `uploads/`
- **Filter Suffix:** `.csv` and `.json`
This ensures only relevant files trigger the queue.

### 4. IAM & Lambda Setup
We create an IAM Execution Role for Lambda granting it:
- `AWSLambdaBasicExecutionRole` (for CloudWatch Logs)
- `AWSLambdaSQSQueueExecutionRole` (to poll SQS)
- Inline Policy to `s3:GetObject` on the Source Bucket and `s3:PutObject` on the Output Bucket.

### 5. Deploy Lambda & Connect
The Python code is zipped and deployed. Finally, an **Event Source Mapping** is created to connect the SQS Queue as the trigger for the Lambda function.

---

> [!TIP]
> **Use the Scripts!** 
> Instead of doing this manually, use the provided scripts in the `scripts/` directory to instantly deploy or tear down this entire architecture.

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

