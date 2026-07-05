import os

docs_dir = r"e:\AWS Hands-on Projects\project-07-cloudwatch-monitoring\docs"

def get_header(filename):
    return f"""
<div align="center">
  <svg width="800" height="150" xmlns="http://www.w3.org/2000/svg">
    <style>
      .bg {{ fill: url(#grad); stroke: #e1e4e8; stroke-width: 2px; rx: 12px; }}
      .title {{ font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; font-size: 28px; font-weight: 800; fill: #ffffff; }}
      .subtitle {{ font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; font-size: 16px; font-weight: 500; fill: #e1e4e8; }}
      .glow {{ animation: pulse 3s infinite alternate; }}
      @keyframes pulse {{
        0% {{ opacity: 0.8; filter: drop-shadow(0 0 4px rgba(255,153,0,0.4)); }}
        100% {{ opacity: 1; filter: drop-shadow(0 0 12px rgba(255,153,0,0.9)); }}
      }}
      @media (prefers-color-scheme: dark) {{
        .bg {{ stroke: #30363d; }}
      }}
    </style>
    <defs>
      <linearGradient id="grad" x1="0%" y1="0%" x2="100%" y2="100%">
        <stop offset="0%" style="stop-color:#232f3e;stop-opacity:1" />
        <stop offset="100%" style="stop-color:#ff9900;stop-opacity:1" />
      </linearGradient>
    </defs>
    <rect width="100%" height="100%" class="bg" />
    <text x="50%" y="45%" dominant-baseline="middle" text-anchor="middle" class="title glow">CloudWatch & SNS Alerts</text>
    <text x="50%" y="70%" dominant-baseline="middle" text-anchor="middle" class="subtitle">{filename}</text>
  </svg>
</div>

<div align="center" style="margin: 30px 0; padding: 15px; border: 1px solid #e1e4e8; border-radius: 8px; background-color: #f6f8fa;">
  <table style="width: 100%; text-align: center; border: none; background: transparent;">
    <tr style="border: none;">
      <td style="width: 33%; border: none;"><a href='../../project-06-rds-ec2/README.md' style='font-size: 16px; text-decoration: none;'>⏪ <b>Previous: Rds Ec2</b></a></td>
      <td style="width: 33%; border: none;"><a href="../README.md" style="font-size: 16px; text-decoration: none;">🏠 <b>Project Home</b></a></td>
      <td style="width: 33%; border: none;"><a href='../../project-08-serverless-rest-api/README.md' style='font-size: 16px; text-decoration: none;'><b>Next: Serverless Rest Api</b> ⏩</a></td>
    </tr>
  </table>
</div>

<br>

<div style="background-color: #fdfdfe; border-left: 4px solid #ff9900; padding: 15px; border-radius: 4px; box-shadow: 0 2px 4px rgba(0,0,0,0.05);">
  <i>The following granular documentation is designed to provide enterprise-level clarity for deploying and managing this AWS architecture. Pay close attention to the architectural specifications and step-by-step methodologies below.</i>
</div>

<br>

"""

footer = """
<br>

<div align="center" style="margin: 30px 0; padding: 15px; border: 1px solid #e1e4e8; border-radius: 8px; background-color: #f6f8fa;">
  <table style="width: 100%; text-align: center; border: none; background: transparent;">
    <tr style="border: none;">
      <td style="width: 33%; border: none;"><a href='../../project-06-rds-ec2/README.md' style='font-size: 16px; text-decoration: none;'>⏪ <b>Previous: Rds Ec2</b></a></td>
      <td style="width: 33%; border: none;"><a href="../README.md" style="font-size: 16px; text-decoration: none;">🏠 <b>Project Home</b></a></td>
      <td style="width: 33%; border: none;"><a href='../../project-08-serverless-rest-api/README.md' style='font-size: 16px; text-decoration: none;'><b>Next: Serverless Rest Api</b> ⏩</a></td>
    </tr>
  </table>
</div>
"""

for filename in os.listdir(docs_dir):
    if not filename.endswith(".md"):
        continue
        
    path = os.path.join(docs_dir, filename)
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()
        
    if "<svg" not in content:
        print(f"Injecting into {filename}...")
        new_content = get_header(filename) + content.lstrip() + footer
        with open(path, "w", encoding="utf-8") as f:
            f.write(new_content)
    else:
        print(f"Skipping {filename}, already formatted.")

print("Done.")
