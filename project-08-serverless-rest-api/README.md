
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
    <text x="50%" y="45%" dominant-baseline="middle" text-anchor="middle" class="title glow">Serverless REST API</text>
    <text x="50%" y="70%" dominant-baseline="middle" text-anchor="middle" class="subtitle">Build highly scalable, zero-maintenance backend systems using modern serverless paradigms.</text>
  </svg>
</div>



<div align="center" style="margin: 30px 0; padding: 15px; border: 1px solid #e1e4e8; border-radius: 8px; background-color: #f6f8fa;">
  <table style="width: 100%; text-align: center; border: none; background: transparent;">
    <tr style="border: none;">
      <td style="width: 33%; border: none;"><a href='../project-07-cloudwatch-monitoring/README.md' style='font-size: 16px; text-decoration: none;'>⏪ <b>Previous: Cloudwatch Monitoring</b></a></td>
      <td style="width: 33%; border: none;"><a href="README.md" style="font-size: 16px; text-decoration: none;">🏠 <b>Project Home</b></a></td>
      <td style="width: 33%; border: none;"><a href='../project-09-cicd-pipeline/README.md' style='font-size: 16px; text-decoration: none;'><b>Next: Cicd Pipeline</b> ⏩</a></td>
    </tr>
  </table>
</div>


<div align="center">
  <img src="architecture/architecture.svg" alt="Project Architecture" width="800"/>
</div>

---

## 🌟 Expansive Overview
> **Core Purpose:** Build highly scalable, zero-maintenance backend systems using modern serverless paradigms.

Serverless REST API is designed to reflect enterprise-grade cloud engineering. This project moves beyond the console basics, demonstrating how AWS services are stitched together to form resilient, scalable, and highly available architectures.

### 💼 Real-World Usage Scenarios
Companies around the globe use this exact architectural pattern for:
- **Mobile App Backends:** Handling millions of unpredictable API requests from iOS/Android apps.
- **IoT Data Ingestion:** Receiving sensor data globally and storing it in DynamoDB instantly.
- **Microservices:** Breaking down monolithic APIs into discrete, independently scalable Lambda functions.

---

## ⚙️ Infrastructure Specifications

<details>
<summary><b>💡 Click to Expand Technical Specifications</b></summary>
<br>

| Component | Specification |
|-----------|---------------|
| **API Gateway** | ** REST API, Lambda Proxy Integration, ANY Method, /{proxy+} route |
| **Compute** | ** AWS Lambda (Python 3.12, 128MB Memory) |
| **Database** | ** Amazon DynamoDB (On-Demand billing, PK: userId) |
| **Security** | ** IAM Execution Role strictly scoped to single DynamoDB table |

</details>

---

## 📂 Project Structure & Performance

To optimize your execution of this project, adhere strictly to the following folder topology. 

| Directory | Core Function |
|-----------|---------------|
| `👉 lambda/` | Python source code for the backend API logic. |
| `👉 docs/` | API endpoints, CORS, and Lambda Proxy details. |
| `👉 scripts/` | Packaging and deployment scripts for API Gateway. |

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
