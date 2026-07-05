import os
import re

base = r"e:\AWS Hands-on Projects\project-03-Launch-EC2-Connect-via-SSH"

# 1. Update README.md
readme_path = os.path.join(base, "README.md")
with open(readme_path, 'r', encoding='utf-8') as f:
    readme_content = f.read()

new_table = """| Step | Bash Script | PowerShell Script | Description |
|------|-------------|-------------------|-------------|
| 01 | `scripts/bash/01-create-key-pair.sh` | `scripts/powershell/01-create-key-pair.ps1` | Generates the SSH key pair |
| 02 | `scripts/bash/02-create-security-group.sh` | `scripts/powershell/02-create-security-group.ps1` | Configures the firewall rules (SSH/HTTP) |
| 03 | `scripts/bash/03-launch-instance.sh` | `scripts/powershell/03-launch-instance.ps1` | Launches the EC2 instance |
| 04 | `scripts/bash/04-connect-ssm.sh` | `scripts/powershell/04-connect-ssm.ps1` | Connects via Session Manager |
| 05 | `scripts/bash/05-cleanup.sh` | `scripts/powershell/05-cleanup.ps1` | Destroys the infrastructure |

### 📸 Screenshots & Validation
Throughout the documentation and `images/` directory, you will find screenshots captured during the deployment process. These visual artifacts serve as verification that the UI steps were successfully executed and validate the final architecture."""

readme_content = re.sub(r'<table>[\s\S]*?</table>', new_table, readme_content)

with open(readme_path, 'w', encoding='utf-8') as f:
    f.write(readme_content)

# 2. Update docs/deployment-guide.md
guide_path = os.path.join(base, "docs", "deployment-guide.md")
with open(guide_path, 'r', encoding='utf-8') as f:
    guide_content = f.read()

# Part 4 Validation: add dummy methods
guide_content = guide_content.replace(
    "## 🌐 PART 4 — VALIDATE THE WEB SERVER\n\n1. Select your running instance", 
    "## 🌐 PART 4 — VALIDATE THE WEB SERVER\n\n### 🖥️ Method 1: AWS Management Console\n1. Select your running instance"
)
dummy_4 = "\n\n### 🐧 Method 2: AWS CLI (Bash)\n*(Validation is a visual check in the browser. See Method 1)*\n\n### 🪟 Method 3: AWS CLI (PowerShell)\n*(Validation is a visual check in the browser. See Method 1)*"
guide_content = guide_content.replace("5. You should see your \"Hello from my first AWS EC2 Web Server!\" message. The User Data script worked!", "5. You should see your \"Hello from my first AWS EC2 Web Server!\" message. The User Data script worked!" + dummy_4)

# Part 6 Cleanup: Add Console steps
p6_console = """### 🖥️ Method 1: AWS Management Console
1. Go to **EC2 Dashboard**.
2. Select **Instances**, select `My-First-Web-Server`, click **Instance state** -> **Terminate instance**.
3. Wait for it to terminate.
4. Select **Security Groups**, select `web-server-sg`, click **Actions** -> **Delete security group**.
5. Select **Key Pairs**, select `my-web-key`, click **Actions** -> **Delete**.
"""
guide_content = guide_content.replace(
    "## 🧹 PART 6 — CLEANUP\n\n### 🐧 Method 1: AWS CLI (Bash)",
    "## 🧹 PART 6 — CLEANUP\n\n" + p6_console + "\n### 🐧 Method 2: AWS CLI (Bash)"
)
guide_content = guide_content.replace("### 🪟 Method 2: AWS CLI (PowerShell)", "### 🪟 Method 3: AWS CLI (PowerShell)")

with open(guide_path, 'w', encoding='utf-8') as f:
    f.write(guide_content)

print("Updated Project 3!")
