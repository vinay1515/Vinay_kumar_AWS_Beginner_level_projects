
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
    <text x="50%" y="70%" dominant-baseline="middle" text-anchor="middle" class="subtitle">Convert manual console clicks into repeatable, version-controlled YAML templates for automated provisioning.</text>
  </svg>
</div>



<div align="center" style="margin: 30px 0; padding: 15px; border: 1px solid #e1e4e8; border-radius: 8px; background-color: #f6f8fa;">
  <table style="width: 100%; text-align: center; border: none; background: transparent;">
    <tr style="border: none;">
      <td style="width: 33%; border: none;"><a href='../project-10-auto-scaling-alb/README.md' style='font-size: 16px; text-decoration: none;'>⏪ <b>Previous: Auto Scaling Alb</b></a></td>
      <td style="width: 33%; border: none;"><a href="README.md" style="font-size: 16px; text-decoration: none;">🏠 <b>Project Home</b></a></td>
      <td style="width: 33%; border: none;"><a href='../project-12-event-driven-pipeline/README.md' style='font-size: 16px; text-decoration: none;'><b>Next: Event Driven Pipeline</b> ⏩</a></td>
    </tr>
  </table>
</div>


<div align="center">
  <img src="architecture/architecture.svg" alt="Project Architecture" width="800"/>
</div>

---

## 🌟 Expansive Overview
> **Core Purpose:** Convert manual console clicks into repeatable, version-controlled YAML templates for automated provisioning.

Infrastructure as Code (IaC) is designed to reflect enterprise-grade cloud engineering. This project moves beyond the console basics, demonstrating how AWS services are stitched together to form resilient, scalable, and highly available architectures.

### 💼 Real-World Usage Scenarios
Companies around the globe use this exact architectural pattern for:
- **Multi-Region Deployment:** Copying a production environment from US to Europe in minutes.
- **Disaster Recovery:** Re-creating a destroyed VPC identically from version control.
- **Auditing:** Using CloudFormation Drift Detection to see if engineers made manual unauthorized changes.

---

## ⚙️ Infrastructure Specifications

<details>
<summary><b>💡 Click to Expand Technical Specifications</b></summary>
<br>

| Component | Specification |
|-----------|---------------|
| **Tooling** | ** AWS CloudFormation (YAML) |
| **Resources Defined** | ** VPC, IGW, Subnets, Route Tables, SG, LaunchTemplate, ASG, ALB |
| **Features Used** | ** Parameters, Outputs, Mappings, !Ref, !GetAtt, !Sub |
| **Operations** | ** Create Stack, Change Sets, Stack Rollback |

</details>

---

## 📂 Project Structure & Performance

To optimize your execution of this project, adhere strictly to the following folder topology. 

| Directory | Core Function |
|-----------|---------------|
| `👉 templates/` | Contains the CloudFormation YAML declarative code. |
| `👉 docs/` | Template syntax guides and drift detection instructions. |
| `👉 scripts/` | CLI scripts for deploying and updating stacks via Change Sets. |

---

## 📚 Granular Documentation Suite
We have broken down the technical manuals into granular, highly detailed Markdown files. Start with the Project Overview and proceed sequentially:

- 📄 [Project Overview](docs/project-overview.md)
- 🏗️ [Architecture Details](docs/architecture.md)
- 🚀 [Deployment Guide](docs/deployment-guide.md)
- 🔐 [Security Protocols](docs/security-protocols.md)
- 🧪 [Testing Procedures](docs/testing-procedures.md)
- 🛠️ [Troubleshooting](docs/troubleshooting.md)
- 🧹 [Cleanup Guide](docs/cleanup-guide.md)

---
*✨ Modernized & Enhanced for the AWS Hands-On Portfolio ✨*
