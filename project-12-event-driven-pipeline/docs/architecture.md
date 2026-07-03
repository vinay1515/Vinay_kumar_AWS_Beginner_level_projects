
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
    <text x="50%" y="70%" dominant-baseline="middle" text-anchor="middle" class="subtitle">Granular Architecture Details</text>
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

This document provides a deep dive into the architectural decisions and components of the Event-Driven Pipeline.

## 🧱 Component Interaction Flow

1. **S3 Bucket (Source)**
   - **Role:** The entry point. Files (`.csv`, `.json`) are uploaded here.
   - **Configuration:** Emits an `s3:ObjectCreated:*` event.
   - **Why?** Triggering directly from S3 provides native, highly reliable event generation without needing a dedicated listener service.

2. **Amazon SQS (Standard Queue)**
   - **Role:** The buffer and message broker.
   - **Configuration:** 30s Visibility Timeout, 4-day Message Retention.
   - **Why not S3 directly to Lambda?** 
     If S3 triggers Lambda directly and Lambda fails (due to a bug or API rate limit), the event is lost. SQS ensures the message is held safely until Lambda successfully processes it.

3. **AWS Lambda (Processor)**
   - **Role:** The compute engine.
   - **Configuration:** Python 3.12, 256MB RAM, 60s Timeout.
   - **Behavior:** Triggered via Event Source Mapping. Reads the message, parses the S3 bucket/key, downloads the file, processes data, and pushes results.

4. **S3 Bucket (Output)**
   - **Role:** Final storage.
   - **Configuration:** Stores processed JSON metadata summaries.

5. **SQS Dead Letter Queue (DLQ)**
   - **Role:** Safety net for "poison pill" messages.
   - **Configuration:** `maxReceiveCount` = 3.
   - **Why?** If a corrupted file is uploaded and Lambda crashes consistently 3 times, the message is routed to the DLQ instead of endlessly looping and wasting compute resources.

## ⚡ Scalability & Fault Tolerance
- **Spike Handling:** If 10,000 files are uploaded at once, SQS acts as a shock absorber. Lambda scales up its concurrent executions automatically to process the backlog efficiently.
- **Retry Logic:** Built inherently into SQS. Messages reappear on the queue if Lambda fails to delete them (handled automatically by the Lambda service when it throws an exception).

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

