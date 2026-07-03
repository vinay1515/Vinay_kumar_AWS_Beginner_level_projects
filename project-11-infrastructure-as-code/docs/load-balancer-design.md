
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
    <text x="50%" y="70%" dominant-baseline="middle" text-anchor="middle" class="subtitle">load-balancer-design.md</text>
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

The Application Load Balancer (ALB) serves as the single point of contact for external users, distributing incoming web traffic across multiple EC2 instances in different Availability Zones.

## Load Balancer Configuration (`ApplicationLoadBalancer`)

- **Scheme**: `internet-facing` (Resolves to public IP addresses).
- **Subnets**: Attached to `PublicSubnetA` and `PublicSubnetB`. The ALB nodes must be placed in public subnets so they have a route to the Internet Gateway.
- **Type**: `application` (Operates at Layer 7 - HTTP/HTTPS, ideal for web traffic).
- **Security Groups**: Associated with `ALBSecurityGroup` which permits inbound HTTP traffic from anywhere (`0.0.0.0/0`).

## Listener Configuration (`ALBListener`)

The Listener process checks for connection requests.

- **Protocol**: `HTTP`
- **Port**: `80`
- **Default Action**: `forward` (Forwards all traffic to the Target Group).

*(Note: In a production environment, you would typically configure an HTTPS listener on Port 443 with an SSL certificate, and redirect Port 80 to 443).*

## Target Group Configuration (`WebServerTargetGroup`)

The Target Group is the destination for the traffic routed by the ALB.

- **Protocol**: `HTTP`
- **Port**: `80`
- **Health Checks**: Checks the root path (`/`) every 30 seconds to ensure the web server is responsive.

The Auto Scaling Group automatically registers new instances with this Target Group, and deregisters instances when they are terminated, ensuring the ALB always has an up-to-date list of healthy backend servers.

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

