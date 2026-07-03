
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
    <text x="50%" y="45%" dominant-baseline="middle" text-anchor="middle" class="title glow">Infrastructure as Code (IaC)</text>
    <text x="50%" y="70%" dominant-baseline="middle" text-anchor="middle" class="subtitle">scaling-policies.md</text>
  </svg>
</div>



<div align="center" style="margin: 30px 0; padding: 15px; border: 1px solid #e1e4e8; border-radius: 8px; background-color: #f6f8fa;">
  <table style="width: 100%; text-align: center; border: none; background: transparent;">
    <tr style="border: none;">
      <td style="width: 33%; border: none;"><a href='../../project-10-auto-scaling-alb/README.md' style='font-size: 16px; text-decoration: none;'>⏪ <b>Previous: Auto Scaling Alb</b></a></td>
      <td style="width: 33%; border: none;"><a href="../README.md" style="font-size: 16px; text-decoration: none;">🏠 <b>Project Home</b></a></td>
      <td style="width: 33%; border: none;"><a href='../../project-12-event-driven-pipeline/README.md' style='font-size: 16px; text-decoration: none;'><b>Next: Event Driven Pipeline</b> ⏩</a></td>
    </tr>
  </table>
</div>


<br>

<div style="background-color: #fdfdfe; border-left: 4px solid #ff9900; padding: 15px; border-radius: 4px; box-shadow: 0 2px 4px rgba(0,0,0,0.05);">
  <i>The following granular documentation is designed to provide enterprise-level clarity for deploying and managing this AWS architecture. Pay close attention to the architectural specifications and step-by-step methodologies below.</i>
</div>

<br>

Our infrastructure uses an AWS Auto Scaling Group (ASG) combined with a Target Tracking Scaling Policy to automatically adjust the number of running EC2 instances based on current demand.

## Auto Scaling Group Configuration

- **Minimum Size (`MinInstances`)**: 2 (Default)
- **Maximum Size (`MaxInstances`)**: 4 (Default)
- **Desired Capacity (`DesiredInstances`)**: 2 (Default)
- **Subnets**: Deployed across `PublicSubnetA` and `PublicSubnetB` for multi-AZ high availability.
- **Health Check Type**: `ELB` (Ensures the ASG replaces instances that fail Load Balancer health checks, not just EC2 status checks).
- **Grace Period**: `120` seconds (Allows instances time to run their User Data script and start Apache before health checks begin).

## Target Tracking Scaling Policy

We utilize a **Target Tracking Scaling Policy** (`CPUScalingPolicy`), which acts similarly to a thermostat. You set the target metric, and AWS handles the underlying CloudWatch alarms and scaling actions.

- **Metric**: `ASGAverageCPUUtilization`
- **Target Value**: `50.0%`
- **Estimated Instance Warmup**: `120` seconds

### How it Works:
1. **Scale Out**: If the average CPU utilization across all instances in the ASG goes above 50%, the ASG will launch new instances (up to the Maximum Size) to bring the average back down.
2. **Scale In**: If the average CPU utilization drops well below 50%, the ASG will terminate instances (down to the Minimum Size) to bring the average back up and save costs.
3. **Warmup**: The 120-second warmup period prevents the ASG from over-scaling by giving newly launched instances time to boot and start contributing to the metrics before further scaling decisions are made.

<br>


<div align="center" style="margin: 30px 0; padding: 15px; border: 1px solid #e1e4e8; border-radius: 8px; background-color: #f6f8fa;">
  <table style="width: 100%; text-align: center; border: none; background: transparent;">
    <tr style="border: none;">
      <td style="width: 33%; border: none;"><a href='../../project-10-auto-scaling-alb/README.md' style='font-size: 16px; text-decoration: none;'>⏪ <b>Previous: Auto Scaling Alb</b></a></td>
      <td style="width: 33%; border: none;"><a href="../README.md" style="font-size: 16px; text-decoration: none;">🏠 <b>Project Home</b></a></td>
      <td style="width: 33%; border: none;"><a href='../../project-12-event-driven-pipeline/README.md' style='font-size: 16px; text-decoration: none;'><b>Next: Event Driven Pipeline</b> ⏩</a></td>
    </tr>
  </table>
</div>

