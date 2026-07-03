
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
    <text x="50%" y="70%" dominant-baseline="middle" text-anchor="middle" class="subtitle">Rigorous Testing Procedures</text>
  </svg>
</div>



<div align="center" style="margin: 30px 0; padding: 15px; border: 1px solid #e1e4e8; border-radius: 8px; background-color: #f6f8fa;">
  <table style="width: 100%; text-align: center; border: none; background: transparent;">
    <tr style="border: none;">
      <td style="width: 33%; border: none;"><a href='../../project-07-cloudwatch-monitoring/README.md' style='font-size: 16px; text-decoration: none;'>⏪ <b>Previous: Cloudwatch Monitoring</b></a></td>
      <td style="width: 33%; border: none;"><a href="../README.md" style="font-size: 16px; text-decoration: none;">🏠 <b>Project Home</b></a></td>
      <td style="width: 33%; border: none;"><a href='../../project-09-cicd-pipeline/README.md' style='font-size: 16px; text-decoration: none;'><b>Next: Cicd Pipeline</b> ⏩</a></td>
    </tr>
  </table>
</div>


<br>

<div style="background-color: #fdfdfe; border-left: 4px solid #ff9900; padding: 15px; border-radius: 4px; box-shadow: 0 2px 4px rgba(0,0,0,0.05);">
  <i>The following granular documentation is designed to provide enterprise-level clarity for deploying and managing this AWS architecture. Pay close attention to the architectural specifications and step-by-step methodologies below.</i>
</div>

<br>

Use `curl` or Postman to test the API endpoints using the Invoke URL provided by API Gateway.

## Create User (POST)
```bash
curl -X POST https://<API_ID>.execute-api.us-east-1.amazonaws.com/prod/users \
-H "Content-Type: application/json" \
-d '{"userId": "1", "name": "Cloud Engineer"}'
```

## Get All Users (GET)
```bash
curl -X GET https://<API_ID>.execute-api.us-east-1.amazonaws.com/prod/users
```

## Get Single User (GET)
```bash
curl -X GET https://<API_ID>.execute-api.us-east-1.amazonaws.com/prod/users/1
```

## Delete User (DELETE)
```bash
curl -X DELETE https://<API_ID>.execute-api.us-east-1.amazonaws.com/prod/users/1
```

<br>


<div align="center" style="margin: 30px 0; padding: 15px; border: 1px solid #e1e4e8; border-radius: 8px; background-color: #f6f8fa;">
  <table style="width: 100%; text-align: center; border: none; background: transparent;">
    <tr style="border: none;">
      <td style="width: 33%; border: none;"><a href='../../project-07-cloudwatch-monitoring/README.md' style='font-size: 16px; text-decoration: none;'>⏪ <b>Previous: Cloudwatch Monitoring</b></a></td>
      <td style="width: 33%; border: none;"><a href="../README.md" style="font-size: 16px; text-decoration: none;">🏠 <b>Project Home</b></a></td>
      <td style="width: 33%; border: none;"><a href='../../project-09-cicd-pipeline/README.md' style='font-size: 16px; text-decoration: none;'><b>Next: Cicd Pipeline</b> ⏩</a></td>
    </tr>
  </table>
</div>

