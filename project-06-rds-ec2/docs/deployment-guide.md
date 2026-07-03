
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
    <text x="50%" y="45%" dominant-baseline="middle" text-anchor="middle" class="title glow">RDS Database & EC2 App</text>
    <text x="50%" y="70%" dominant-baseline="middle" text-anchor="middle" class="subtitle">Step-by-Step Deployment Guide</text>
  </svg>
</div>



<div align="center" style="margin: 30px 0; padding: 15px; border: 1px solid #e1e4e8; border-radius: 8px; background-color: #f6f8fa;">
  <table style="width: 100%; text-align: center; border: none; background: transparent;">
    <tr style="border: none;">
      <td style="width: 33%; border: none;"><a href='../../project-05-Custom-VPC/README.md' style='font-size: 16px; text-decoration: none;'>⏪ <b>Previous: Custom Vpc</b></a></td>
      <td style="width: 33%; border: none;"><a href="../README.md" style="font-size: 16px; text-decoration: none;">🏠 <b>Project Home</b></a></td>
      <td style="width: 33%; border: none;"><a href='../../project-07-cloudwatch-monitoring/README.md' style='font-size: 16px; text-decoration: none;'><b>Next: Cloudwatch Monitoring</b> ⏩</a></td>
    </tr>
  </table>
</div>


<br>

<div style="background-color: #fdfdfe; border-left: 4px solid #ff9900; padding: 15px; border-radius: 4px; box-shadow: 0 2px 4px rgba(0,0,0,0.05);">
  <i>The following granular documentation is designed to provide enterprise-level clarity for deploying and managing this AWS architecture. Pay close attention to the architectural specifications and step-by-step methodologies below.</i>
</div>

<br>

## Step 1: Create the Subnet Group & Security Groups
1. Navigate to RDS > Subnet Groups. Create one utilizing your Private Subnets.
2. Create `Web-SG` (Port 80/22 inbound).
3. Create `DB-SG` (Port 3306 inbound from `Web-SG`).

## Step 2: Store Credentials
1. Navigate to Secrets Manager. Store a new secret (Other type).
2. Key/Value pairs: `username`, `password`, `port`, `dbname`. Name it `rds/myapp/credentials`.

## Step 3: Launch RDS
1. Create Database > MySQL.
2. Select Free Tier (db.t3.micro).
3. Set master username/password to match the Secrets Manager values.
4. Under Connectivity, select your VPC, the DB Subnet Group, and `DB-SG`. Ensure Public Access is **No**.

## Step 4: Launch EC2 App Server
1. Create an IAM Role granting access to Secrets Manager and attach it to an EC2 instance.
2. Launch the EC2 instance into a Public Subnet with `Web-SG`.
3. SSH into EC2, install the `mysql` client, retrieve the secret via AWS CLI, and connect to the RDS endpoint.

<br>


<div align="center" style="margin: 30px 0; padding: 15px; border: 1px solid #e1e4e8; border-radius: 8px; background-color: #f6f8fa;">
  <table style="width: 100%; text-align: center; border: none; background: transparent;">
    <tr style="border: none;">
      <td style="width: 33%; border: none;"><a href='../../project-05-Custom-VPC/README.md' style='font-size: 16px; text-decoration: none;'>⏪ <b>Previous: Custom Vpc</b></a></td>
      <td style="width: 33%; border: none;"><a href="../README.md" style="font-size: 16px; text-decoration: none;">🏠 <b>Project Home</b></a></td>
      <td style="width: 33%; border: none;"><a href='../../project-07-cloudwatch-monitoring/README.md' style='font-size: 16px; text-decoration: none;'><b>Next: Cloudwatch Monitoring</b> ⏩</a></td>
    </tr>
  </table>
</div>

