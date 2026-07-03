
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
    <text x="50%" y="45%" dominant-baseline="middle" text-anchor="middle" class="title glow">EC2 Launch & SSH</text>
    <text x="50%" y="70%" dominant-baseline="middle" text-anchor="middle" class="subtitle">troubleshooting-instrustions.md</text>
  </svg>
</div>



<div align="center" style="margin: 30px 0; padding: 15px; border: 1px solid #e1e4e8; border-radius: 8px; background-color: #f6f8fa;">
  <table style="width: 100%; text-align: center; border: none; background: transparent;">
    <tr style="border: none;">
      <td style="width: 33%; border: none;"><a href='../../project-02-s3-static-website/README.md' style='font-size: 16px; text-decoration: none;'>⏪ <b>Previous: S3 Static Website</b></a></td>
      <td style="width: 33%; border: none;"><a href="../README.md" style="font-size: 16px; text-decoration: none;">🏠 <b>Project Home</b></a></td>
      <td style="width: 33%; border: none;"><a href='../../project-04-s3-versioning/README.md' style='font-size: 16px; text-decoration: none;'><b>Next: S3 Versioning</b> ⏩</a></td>
    </tr>
  </table>
</div>


<br>

<div style="background-color: #fdfdfe; border-left: 4px solid #ff9900; padding: 15px; border-radius: 4px; box-shadow: 0 2px 4px rgba(0,0,0,0.05);">
  <i>The following granular documentation is designed to provide enterprise-level clarity for deploying and managing this AWS architecture. Pay close attention to the architectural specifications and step-by-step methodologies below.</i>
</div>

<br>

This guide covers common issues encountered when connecting to EC2 instances via PuTTY, Session Manager, or accessing web servers, along with their root causes and immediate resolutions.

---

## Quick Reference Troubleshooting Matrix

| Problem | Potential Cause | Verification & Fix |
| :--- | :--- | :--- |
| **PuTTY shows:**<br>`Connection refused` | Security group is missing the SSH rule, or the instance is still booting up. | 1. Check that the security group has port `22` open to your current IP.<br>2. Wait for the instance status checks to show **2/2 passed** in the EC2 console. |
| **PuTTY shows:**<br>`Connection timed out` | Incorrect IP address used, or the security group is not attached to the instance. | 1. Verify the **Public IPv4 address** directly in the EC2 console.<br>2. Confirm that the `ec2-web-sg` security group is actively attached to the instance. |
| **PuTTY shows:**<br>`No supported authentication methods` | The wrong private key file format or path was selected in the PuTTY configuration. | Open your PuTTY session settings, browse your authentication credentials again, and specifically select the valid `.ppk` file. |
| **Apache page not loading**<br>in browser | The HTTP rule is missing in the security group, or the Apache service is not running. | 1. Check the security group for an inbound rule allowing port `80`.<br>2. SSH into the instance and start the service manually:<br>`sudo systemctl start httpd` |
| **Session Manager**<br>`Connect` button is greyed out | The required IAM role is not attached, or the Systems Manager (SSM) agent is still initializing. | 1. Ensure the instance IAM role includes the `AmazonSSMManagedInstanceCore` policy.<br>2. Wait up to 5 minutes after attaching the role for the agent to check in. |
| **Public IP changed**<br>after an instance restart | Default EC2 public IP addresses are dynamic and release upon instance stop/start. | This is expected behavior. Update your connection string with the new IP shown in the console. For a permanent fix, associate an **Elastic IP** to the instance. |
| **AWS CLI Command:**<br>`aws ec2 wait` times out | The instance initialization or state transition is taking longer than the default timeout window. | Run the manual status description command to check the exact state of the resource:<br>`aws ec2 describe-instances` |

---

> [!TIP]
> **Security Best Practice:** When opening port 22 for SSH troubleshooting, avoid using `0.0.0.0/0`. Always restrict the source to **My IP** to secure your instance from unauthorized access attempts.

<br>


<div align="center" style="margin: 30px 0; padding: 15px; border: 1px solid #e1e4e8; border-radius: 8px; background-color: #f6f8fa;">
  <table style="width: 100%; text-align: center; border: none; background: transparent;">
    <tr style="border: none;">
      <td style="width: 33%; border: none;"><a href='../../project-02-s3-static-website/README.md' style='font-size: 16px; text-decoration: none;'>⏪ <b>Previous: S3 Static Website</b></a></td>
      <td style="width: 33%; border: none;"><a href="../README.md" style="font-size: 16px; text-decoration: none;">🏠 <b>Project Home</b></a></td>
      <td style="width: 33%; border: none;"><a href='../../project-04-s3-versioning/README.md' style='font-size: 16px; text-decoration: none;'><b>Next: S3 Versioning</b> ⏩</a></td>
    </tr>
  </table>
</div>

