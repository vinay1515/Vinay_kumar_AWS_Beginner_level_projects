import os
import re

base = r"e:\AWS Hands-on Projects\project-05-Custom-VPC"

# 1. Update README.md
readme_path = os.path.join(base, "README.md")
with open(readme_path, 'r', encoding='utf-8') as f:
    readme_content = f.read()

new_table = """| Step | Bash Script | PowerShell Script | Description |
|------|-------------|-------------------|-------------|
| 01 | `scripts/bash/01-create-vpc.sh` | `scripts/powershell/01-create-vpc.ps1` | Provisions the Custom VPC and 4 subnets |
| 02 | `scripts/bash/02-create-route-tables.sh` | `scripts/powershell/02-create-route-tables.ps1` | Creates IGW, Route Tables, and subnet associations |
| 03 | `scripts/bash/03-create-nat-gateway.sh` | `scripts/powershell/03-create-nat-gateway.ps1` | Deploys NAT Gateway with Elastic IP |
| 04 | `scripts/bash/04-create-security-groups.sh` | `scripts/powershell/04-create-security-groups.ps1` | Configures public bastion and private security groups |
| 05 | `scripts/bash/05-launch-instances.sh` | `scripts/powershell/05-launch-instances.ps1` | Launches EC2 instances to test routing |
| 06 | `scripts/bash/06-cleanup.sh` | `scripts/powershell/06-cleanup.ps1` | Tears down the entire VPC architecture |

### 📸 Screenshots & Validation
Throughout the documentation and `images/` directory, you will find screenshots captured during the deployment process. These visual artifacts serve as verification that the UI steps were successfully executed and validate the final architecture."""

readme_content = re.sub(r'<table>[\s\S]*?</table>', new_table, readme_content)

with open(readme_path, 'w', encoding='utf-8') as f:
    f.write(readme_content)

# 2. Update docs/deployment-guide.md
guide_path = os.path.join(base, "docs", "deployment-guide.md")
with open(guide_path, 'r', encoding='utf-8') as f:
    guide_content = f.read()

# Part 9 Cleanup: Add Console steps
p9_console = """### 🖥️ Method 1: AWS Management Console
1. Go to **EC2** -> **Instances** and terminate both `bastion-host` and `private-instance`. Wait for termination.
2. Go to **VPC** -> **NAT Gateways**, select `my-nat-gateway`, and delete it. Wait until deleted.
3. Go to **VPC** -> **Elastic IPs**, select the EIP, click **Actions** -> **Release**.
4. Go to **EC2** -> **Security Groups** and delete `private-sg` and `bastion-sg`.
5. Go to **VPC** -> **Subnets** and delete all 4 subnets.
6. Go to **VPC** -> **Route Tables** and delete the public and private tables.
7. Go to **VPC** -> **Internet Gateways**, detach `my-vpc-igw` from the VPC, then delete it.
8. Go to **VPC** -> **Your VPCs**, select `my-custom-vpc` and delete it.
"""
guide_content = guide_content.replace(
    "## 🧹 PART 9 — CLEANUP\n\nRun in this exact order — dependencies matter:\n\n### 🐧 Method 1: AWS CLI (Bash)",
    "## 🧹 PART 9 — CLEANUP\n\nRun in this exact order — dependencies matter:\n\n" + p9_console + "\n### 🐧 Method 2: AWS CLI (Bash)"
)
guide_content = guide_content.replace("### 🪟 Method 2: AWS CLI (PowerShell)\n", "### 🪟 Method 3: AWS CLI (PowerShell)\n")

with open(guide_path, 'w', encoding='utf-8') as f:
    f.write(guide_content)

print("Updated Project 5!")
