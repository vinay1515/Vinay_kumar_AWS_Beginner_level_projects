
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
    <text x="50%" y="45%" dominant-baseline="middle" text-anchor="middle" class="title glow">Custom VPC Architecture</text>
    <text x="50%" y="70%" dominant-baseline="middle" text-anchor="middle" class="subtitle">Step-by-Step Deployment Guide</text>
  </svg>
</div>



<div align="center" style="margin: 30px 0; padding: 15px; border: 1px solid #e1e4e8; border-radius: 8px; background-color: #f6f8fa;">
  <table style="width: 100%; text-align: center; border: none; background: transparent;">
    <tr style="border: none;">
      <td style="width: 33%; border: none;"><a href='../../project-04-s3-versioning/README.md' style='font-size: 16px; text-decoration: none;'>⏪ <b>Previous: S3 Versioning</b></a></td>
      <td style="width: 33%; border: none;"><a href="../README.md" style="font-size: 16px; text-decoration: none;">🏠 <b>Project Home</b></a></td>
      <td style="width: 33%; border: none;"><a href='../../project-06-rds-ec2/README.md' style='font-size: 16px; text-decoration: none;'><b>Next: Rds Ec2</b> ⏩</a></td>
    </tr>
  </table>
</div>


<br>

<div style="background-color: #fdfdfe; border-left: 4px solid #ff9900; padding: 15px; border-radius: 4px; box-shadow: 0 2px 4px rgba(0,0,0,0.05);">
  <i>The following granular documentation is designed to provide enterprise-level clarity for deploying and managing this AWS architecture. Pay close attention to the architectural specifications and step-by-step methodologies below.</i>
</div>

<br>

## Step 1: Core Networking
1. Create VPC `10.0.0.0/16`.
2. Create 2 Public Subnets and 2 Private Subnets across two AZs.
3. Create an Internet Gateway and attach it to the VPC.

## Step 2: NAT Gateway
1. Allocate an Elastic IP.
2. Create a NAT Gateway in `Public Subnet A` using the allocated EIP.

## Step 3: Routing
1. Create a **Public Route Table**. Add route `0.0.0.0/0` -> IGW. Associate with both Public Subnets.
2. Create a **Private Route Table**. Add route `0.0.0.0/0` -> NAT Gateway. Associate with both Private Subnets.

## Step 4: Security Groups
1. Create `Bastion-SG`: Allow Port 22 from your specific IP.
2. Create `Private-SG`: Allow Port 22 from the `Bastion-SG` ID.

## Step 5: Test Instances
1. Launch an EC2 instance in the Public Subnet using `Bastion-SG`.
2. Launch an EC2 instance in the Private Subnet using `Private-SG`.

<br>


<div align="center" style="margin: 30px 0; padding: 15px; border: 1px solid #e1e4e8; border-radius: 8px; background-color: #f6f8fa;">
  <table style="width: 100%; text-align: center; border: none; background: transparent;">
    <tr style="border: none;">
      <td style="width: 33%; border: none;"><a href='../../project-04-s3-versioning/README.md' style='font-size: 16px; text-decoration: none;'>⏪ <b>Previous: S3 Versioning</b></a></td>
      <td style="width: 33%; border: none;"><a href="../README.md" style="font-size: 16px; text-decoration: none;">🏠 <b>Project Home</b></a></td>
      <td style="width: 33%; border: none;"><a href='../../project-06-rds-ec2/README.md' style='font-size: 16px; text-decoration: none;'><b>Next: Rds Ec2</b> ⏩</a></td>
    </tr>
  </table>
</div>

