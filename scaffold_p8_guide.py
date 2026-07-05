guide_path = r"e:\AWS Hands-on Projects\project-08-serverless-rest-api\docs\deployment-guide.md"

parts = [
    "CREATE DYNAMODB",
    "CREATE LAMBDA ROLE",
    "PACKAGE LAMBDA",
    "DEPLOY LAMBDA",
    "CREATE API GATEWAY",
    "TEST API",
    "MONITOR CLOUDWATCH",
    "UPDATE LAMBDA",
    "CLEANUP"
]

content = """# Deployment Guide

This document provides the deployment steps for Project 08 in three formats: **AWS Management Console**, **Bash**, and **PowerShell**.

## Prerequisites
- AWS CLI configured
- Appropriate IAM permissions
- Python 3.12+

---

"""

for i, part in enumerate(parts, 1):
    content += f"## 🏗️ PART {i} — {part}\n\n"
    content += f"### 🖥️ Method 1: AWS Management Console\n"
    content += f"*(Console instructions for {part.lower()}...)*\n\n"
    
    content += f"### 🐧 Method 2: AWS CLI (Bash)\n"
    content += f"```bash\n# [Insert Bash script for 0{i}-{part.lower().replace(' ', '-')} here]\n```\n\n"
    
    content += f"### 🪟 Method 3: AWS CLI (PowerShell)\n"
    content += f"```powershell\n# [Insert PowerShell script for 0{i}-{part.lower().replace(' ', '-')} here]\n```\n\n"
    
    content += "---\n\n"

# Remove trailing ---
content = content.rstrip("-\n ") + "\n"

with open(guide_path, "w", encoding="utf-8") as f:
    f.write(content)

print("Scaffolded docs/deployment-guide.md")
