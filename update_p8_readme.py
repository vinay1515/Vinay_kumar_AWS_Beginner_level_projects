import re

readme_path = r"e:\AWS Hands-on Projects\project-08-serverless-rest-api\README.md"

with open(readme_path, "r", encoding="utf-8") as f:
    content = f.read()

# Replace HTML table with Markdown table
markdown_table = """
| Step | Bash Script | PowerShell Script | Description |
|:---:|:---|:---|:---|
| 1 | `scripts/bash/01-create-dynamodb.sh` | `scripts/powershell/01-create-dynamodb.ps1` | Create DynamoDB table |
| 2 | `scripts/bash/02-create-lambda-role.sh` | `scripts/powershell/02-create-lambda-role.ps1` | Create IAM role for Lambda |
| 3 | `scripts/bash/03-package-lambda.sh` | `scripts/powershell/03-package-lambda.ps1` | Package Lambda function zip |
| 4 | `scripts/bash/04-deploy-lambda.sh` | `scripts/powershell/04-deploy-lambda.ps1` | Deploy Lambda function |
| 5 | `scripts/bash/05-create-api-gateway.sh` | `scripts/powershell/05-create-api-gateway.ps1` | Create and configure API Gateway |
| 6 | `scripts/bash/06-test-api.sh` | `scripts/powershell/06-test-api.ps1` | Test API endpoints |
| 7 | `scripts/bash/07-monitor-cloudwatch.sh` | `scripts/powershell/07-monitor-cloudwatch.ps1` | Monitor via CloudWatch |
| 8 | `scripts/bash/08-update-lambda.sh` | `scripts/powershell/08-update-lambda.ps1` | Update Lambda code |
| 9 | `scripts/bash/09-cleanup.sh` | `scripts/powershell/09-cleanup.ps1` | Clean up resources |
"""

content = re.sub(r'<table>.*?</table>', markdown_table.strip(), content, flags=re.DOTALL)

# Add Screenshots & Validation section
screenshots_section = """
### 📸 Screenshots & Validation

> *Add screenshots here validating the deployment (e.g., API Gateway console, Postman tests, DynamoDB items).*

## 📚 Documentation Suite
"""

content = content.replace("## 📚 Documentation Suite", screenshots_section.strip() + "\n")

with open(readme_path, "w", encoding="utf-8") as f:
    f.write(content)

print("Updated README.md")
