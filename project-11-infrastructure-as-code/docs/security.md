
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
    <text x="50%" y="70%" dominant-baseline="middle" text-anchor="middle" class="subtitle">security.md</text>
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

This project follows the Principle of Least Privilege when designing network security for the infrastructure. The primary security mechanism is the use of chained AWS Security Groups.

## Security Groups

The stack defines two security groups that work together:

### 1. ALB Security Group (`ALBSecurityGroup`)
This group is attached to the Application Load Balancer. It is the public face of the application.
- **Inbound (Ingress)**: Allows HTTP (Port `80`) traffic from **Anywhere** (`0.0.0.0/0`).
- **Outbound (Egress)**: By default in CloudFormation, allows all outbound traffic.

### 2. EC2 Security Group (`EC2SecurityGroup`)
This group is attached to the EC2 instances via the Launch Template. It protects the backend servers.
- **Inbound (Ingress)**: Allows HTTP (Port `80`) traffic **ONLY** from the `ALBSecurityGroup`. 
- **Outbound (Egress)**: Allows all outbound traffic (necessary for `yum update` and downloading packages during the User Data script execution).

**Security Benefit:**
By specifying the `ALBSecurityGroup` as the source in the `EC2SecurityGroup` ingress rule (`SourceSecurityGroupId: !Ref ALBSecurityGroup`), we prevent users from bypassing the Load Balancer and accessing the EC2 instances directly via their public IPs.

## SSH Access
By default, the template **does not** open Port 22 (SSH) in the `EC2SecurityGroup`. This is a best practice for immutable infrastructure where instances are replaced rather than patched manually. 
If SSH access is absolutely required for debugging, you should either:
1. Use AWS Systems Manager Session Manager (requires adding an IAM Instance Profile to the Launch Template).
2. Add a Port 22 ingress rule to the `EC2SecurityGroup` restricted strictly to your administrative IP address (never `0.0.0.0/0`).

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

