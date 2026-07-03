
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
    <text x="50%" y="70%" dominant-baseline="middle" text-anchor="middle" class="subtitle">Build an asynchronous, decoupled architecture where actions (S3 uploads) trigger downstream processing (SQS, Lambda).</text>
  </svg>
</div>



<div align="center" style="margin: 30px 0; padding: 15px; border: 1px solid #e1e4e8; border-radius: 8px; background-color: #f6f8fa;">
  <table style="width: 100%; text-align: center; border: none; background: transparent;">
    <tr style="border: none;">
      <td style="width: 33%; border: none;"><a href='../project-11-infrastructure-as-code/README.md' style='font-size: 16px; text-decoration: none;'>⏪ <b>Previous: Infrastructure As Code</b></a></td>
      <td style="width: 33%; border: none;"><a href="README.md" style="font-size: 16px; text-decoration: none;">🏠 <b>Project Home</b></a></td>
      <td style="width: 33%; border: none;"><i>(Final Project)</i></td>
    </tr>
  </table>
</div>


<div align="center">
  <img src="architecture/architecture.svg" alt="Project Architecture" width="800"/>
</div>

---

## 🌟 Expansive Overview
> **Core Purpose:** Build an asynchronous, decoupled architecture where actions (S3 uploads) trigger downstream processing (SQS, Lambda).

Event-Driven Data Pipeline is designed to reflect enterprise-grade cloud engineering. This project moves beyond the console basics, demonstrating how AWS services are stitched together to form resilient, scalable, and highly available architectures.

### 💼 Real-World Usage Scenarios
Companies around the globe use this exact architectural pattern for:
- **Image Processing:** Automatically generating thumbnails when a user uploads a profile picture.
- **Order Processing:** Placing customer orders into an SQS queue to handle database throttling during peaks.
- **Log Analytics:** Streaming logs into S3, triggering Lambda to transform and push to OpenSearch.

---

## ⚙️ Infrastructure Specifications

<details>
<summary><b>💡 Click to Expand Technical Specifications</b></summary>
<br>

| Component | Specification |
|-----------|---------------|
| **Event Source** | ** Amazon S3 (s3:ObjectCreated:* events) |
| **Queueing** | ** Amazon SQS (Standard Queue, Dead Letter Queue configured) |
| **Compute** | ** AWS Lambda (Event Source Mapping to SQS, Batch Size 10) |
| **Notification** | ** Amazon SNS (For processing failures/alerts) |

</details>

---

## 📂 Project Structure & Performance

To optimize your execution of this project, adhere strictly to the following folder topology. 

| Directory | Core Function |
|-----------|---------------|
| `👉 lambda/` | Python logic for reading and acknowledging SQS messages. |
| `👉 docs/` | Event tracing, queue configuration, and decoupled architecture guides. |
| `👉 scripts/` | Scripts to upload test data and monitor the queue. |

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
