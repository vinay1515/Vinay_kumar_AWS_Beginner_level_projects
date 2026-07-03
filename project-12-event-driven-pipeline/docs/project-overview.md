
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
    <text x="50%" y="70%" dominant-baseline="middle" text-anchor="middle" class="subtitle">Expansive Project Overview</text>
  </svg>
</div>



<div align="center" style="margin: 30px 0; padding: 15px; border: 1px solid #e1e4e8; border-radius: 8px; background-color: #f6f8fa;">
  <table style="width: 100%; text-align: center; border: none; background: transparent;">
    <tr style="border: none;">
      <td style="width: 33%; border: none;"><a href='../../project-11-infrastructure-as-code/README.md' style='font-size: 16px; text-decoration: none;'>⏪ <b>Previous: Infrastructure As Code</b></a></td>
      <td style="width: 33%; border: none;"><a href="../README.md" style="font-size: 16px; text-decoration: none;">🏠 <b>Project Home</b></a></td>
      <td style="width: 33%; border: none;"><i>(Final Project)</i></td>
    </tr>
  </table>
</div>


<br>

<div style="background-color: #fdfdfe; border-left: 4px solid #ff9900; padding: 15px; border-radius: 4px; box-shadow: 0 2px 4px rgba(0,0,0,0.05);">
  <i>The following granular documentation is designed to provide enterprise-level clarity for deploying and managing this AWS architecture. Pay close attention to the architectural specifications and step-by-step methodologies below.</i>
</div>

<br>

## 🎯 The Business Problem
In modern architectures, systems need to react in real-time to external inputs. If you have an application where users upload files, you don't want your web server hanging and synchronously processing those files (which could be gigabytes in size). Doing so wastes web server compute time and ruins the user experience.

## 🚀 The Solution
This project introduces **Asynchronous Event-Driven Processing**.

1. **Uploads are fast**: The user uploads directly to S3.
2. **Decoupled execution**: S3 fires an event to an SQS message queue.
3. **Scalable processing**: Lambda functions poll the queue and process the files in the background.

## 🔑 Key Concepts Covered
- **Decoupling:** Breaking a large monolithic process into independent parts communicating via queues.
- **Message Queues:** Buffering work to prevent overwhelming backend workers during usage spikes.
- **Idempotency & Retries:** Ensuring that if a file processing step fails, it can be retried safely.

## 🏢 Real-World Use Cases
- **Media Processing:** A user uploads a 4K video, and a background task encodes it into 1080p, 720p, and 480p.
- **Data Ingestion (ETL):** An external vendor drops a nightly CSV into an S3 bucket. It triggers a pipeline to clean and load the data into a data warehouse.
- **Log Aggregation:** Server logs are shipped to S3 and automatically scanned for security anomalies by Lambda.

<br>


<div align="center" style="margin: 30px 0; padding: 15px; border: 1px solid #e1e4e8; border-radius: 8px; background-color: #f6f8fa;">
  <table style="width: 100%; text-align: center; border: none; background: transparent;">
    <tr style="border: none;">
      <td style="width: 33%; border: none;"><a href='../../project-11-infrastructure-as-code/README.md' style='font-size: 16px; text-decoration: none;'>⏪ <b>Previous: Infrastructure As Code</b></a></td>
      <td style="width: 33%; border: none;"><a href="../README.md" style="font-size: 16px; text-decoration: none;">🏠 <b>Project Home</b></a></td>
      <td style="width: 33%; border: none;"><i>(Final Project)</i></td>
    </tr>
  </table>
</div>

