import os
import re

base = r"e:\AWS Hands-on Projects\project-06-rds-ec2"

# 1. Update README.md
readme_path = os.path.join(base, "README.md")
with open(readme_path, 'r', encoding='utf-8') as f:
    readme_content = f.read()

new_table = """| Step | Bash Script | PowerShell Script | Description |
|------|-------------|-------------------|-------------|
| 01 | `scripts/bash/01-vpc-setup.sh` | `scripts/powershell/01-vpc-setup.ps1` | Rebuilds the Custom VPC architecture |
| 02 | `scripts/bash/02-security-groups.sh` | `scripts/powershell/02-security-groups.ps1` | Configures Security Group chaining |
| 03 | `scripts/bash/03-rds-subnet-group.sh` | `scripts/powershell/03-rds-subnet-group.ps1` | Creates DB subnet group across 2 AZs |
| 04 | `scripts/bash/04-secrets-manager.sh` | `scripts/powershell/04-secrets-manager.ps1` | Stores DB credentials securely |
| 05 | `scripts/bash/05-rds-instance.sh` | `scripts/powershell/05-rds-instance.ps1` | Provisions the RDS MySQL database |
| 06 | `scripts/bash/06-iam-role.sh` | `scripts/powershell/06-iam-role.ps1` | Creates EC2 IAM role for Secrets Manager |
| 07 | `scripts/bash/07-ec2-app.sh` | `scripts/powershell/07-ec2-app.ps1` | Launches EC2 instance with user data |
| 08 | `scripts/bash/08-cleanup.sh` | `scripts/powershell/08-cleanup.ps1` | Tears down the entire architecture |

### 📸 Screenshots & Validation
Throughout the documentation and `images/` directory, you will find screenshots captured during the deployment process. These visual artifacts serve as verification that the UI steps were successfully executed and validate the final architecture."""

readme_content = re.sub(r'<table>[\s\S]*?</table>', new_table, readme_content)

with open(readme_path, 'w', encoding='utf-8') as f:
    f.write(readme_content)

print("Updated Project 6!")
