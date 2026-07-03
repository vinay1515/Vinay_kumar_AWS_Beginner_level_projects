
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
    <text x="50%" y="45%" dominant-baseline="middle" text-anchor="middle" class="title glow">Auto Scaling & ALB</text>
    <text x="50%" y="70%" dominant-baseline="middle" text-anchor="middle" class="subtitle">Step-by-Step Deployment Guide</text>
  </svg>
</div>



<div align="center" style="margin: 30px 0; padding: 15px; border: 1px solid #e1e4e8; border-radius: 8px; background-color: #f6f8fa;">
  <table style="width: 100%; text-align: center; border: none; background: transparent;">
    <tr style="border: none;">
      <td style="width: 33%; border: none;"><a href='../../project-09-cicd-pipeline/README.md' style='font-size: 16px; text-decoration: none;'>⏪ <b>Previous: Cicd Pipeline</b></a></td>
      <td style="width: 33%; border: none;"><a href="../README.md" style="font-size: 16px; text-decoration: none;">🏠 <b>Project Home</b></a></td>
      <td style="width: 33%; border: none;"><a href='../../project-11-infrastructure-as-code/README.md' style='font-size: 16px; text-decoration: none;'><b>Next: Infrastructure As Code</b> ⏩</a></td>
    </tr>
  </table>
</div>


<br>

<div style="background-color: #fdfdfe; border-left: 4px solid #ff9900; padding: 15px; border-radius: 4px; box-shadow: 0 2px 4px rgba(0,0,0,0.05);">
  <i>The following granular documentation is designed to provide enterprise-level clarity for deploying and managing this AWS architecture. Pay close attention to the architectural specifications and step-by-step methodologies below.</i>
</div>

<br>

## Step 1: Create Launch Template
1. Navigate to EC2 > Launch Templates. Create a new template.
2. Select Amazon Linux 2023, `t2.micro`, and your `EC2-SG`.
3. Under Advanced > User Data, insert a bash script to install `httpd` and echo the Instance ID to `index.html`.

## Step 2: Create Target Group
1. Navigate to Target Groups. Create a new group (Instances, Port 80, HTTP).
2. Set Health Check path to `/`. Do not register any targets manually (the ASG will do this).

## Step 3: Create Application Load Balancer
1. Navigate to Load Balancers. Create an ALB.
2. Select Internet-facing. Select your VPC and at least two Public Subnets.
3. Attach `ALB-SG`. Add a listener for Port 80 forwarding to the Target Group from Step 2.

## Step 4: Create Auto Scaling Group
1. Navigate to Auto Scaling Groups.
2. Select your Launch Template. Select your VPC and the two Public Subnets.
3. Attach to an existing load balancer (choose the Target Group).
4. Turn on ELB Health Checks.
5. Set Min=2, Desired=2, Max=4. Add a Target Tracking Scaling Policy for CPU > 50%.

<br>


<div align="center" style="margin: 30px 0; padding: 15px; border: 1px solid #e1e4e8; border-radius: 8px; background-color: #f6f8fa;">
  <table style="width: 100%; text-align: center; border: none; background: transparent;">
    <tr style="border: none;">
      <td style="width: 33%; border: none;"><a href='../../project-09-cicd-pipeline/README.md' style='font-size: 16px; text-decoration: none;'>⏪ <b>Previous: Cicd Pipeline</b></a></td>
      <td style="width: 33%; border: none;"><a href="../README.md" style="font-size: 16px; text-decoration: none;">🏠 <b>Project Home</b></a></td>
      <td style="width: 33%; border: none;"><a href='../../project-11-infrastructure-as-code/README.md' style='font-size: 16px; text-decoration: none;'><b>Next: Infrastructure As Code</b> ⏩</a></td>
    </tr>
  </table>
</div>

