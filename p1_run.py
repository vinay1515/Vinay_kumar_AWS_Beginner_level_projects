import os
import re

base = r"e:\AWS Hands-on Projects\project-01-iam-setup"

# 1. Update README.md
readme_path = os.path.join(base, "README.md")
with open(readme_path, 'r', encoding='utf-8') as f:
    readme_content = f.read()

# Replace the HTML table with Markdown table
old_table = """<table>
<tr><th>Order</th><th>Step</th><th>Bash Script (🐧)</th><th>PowerShell Script (🖥️)</th><th>Description</th></tr>
<tr><td>1</td><td>Setup IAM User</td><td><code>scripts/bash/setup-iam-user.sh</code></td><td><code>scripts/powershell/setup-iam-user.ps1</code></td><td>Creates IAM user, group, and policies</td></tr>
<tr><td>2</td><td>Setup Billing Alarm</td><td><code>scripts/bash/setup-billing-alarm.sh</code></td><td><code>scripts/powershell/setup-billing-alarm.ps1</code></td><td>Creates SNS topic and CloudWatch billing alarm</td></tr>
<tr><td>3</td><td>Verify Setup</td><td><code>scripts/bash/verify_setup.sh</code></td><td><code>scripts/powershell/verify_setup.ps1</code></td><td>Validates the creation of all resources</td></tr>
</table>"""

new_table = """| Step | Bash Script | PowerShell Script | Description |
|------|-------------|-------------------|-------------|
| 01 | `scripts/bash/setup-iam-user.sh` | `scripts/powershell/setup-iam-user.ps1` | Creates IAM user, group, and policies |
| 02 | `scripts/bash/setup-billing-alarm.sh` | `scripts/powershell/setup-billing-alarm.ps1` | Creates SNS topic and CloudWatch billing alarm |
| 03 | `scripts/bash/verify_setup.sh` | `scripts/powershell/verify_setup.ps1` | Validates the creation of all resources |

### 📸 Screenshots & Validation
Throughout the documentation and `images/` directory, you will find screenshots captured during the deployment process. These visual artifacts serve as verification that the UI steps were successfully executed and validate the final architecture."""

readme_content = readme_content.replace(old_table, new_table)
with open(readme_path, 'w', encoding='utf-8') as f:
    f.write(readme_content)

# 2. Update docs/deployment-guide.md
guide_path = os.path.join(base, "docs", "deployment-guide.md")
with open(guide_path, 'r', encoding='utf-8') as f:
    guide_content = f.read()

# Part 1: SECURE THE ROOT ACCOUNT
p1_dummy = "\n\n### 🐧 Method 2: AWS CLI (Bash)\n*(This task is a root-level security operation and must be performed via the Management Console)*\n\n### 🪟 Method 3: AWS CLI (PowerShell)\n*(This task is a root-level security operation and must be performed via the Management Console)*"
guide_content = guide_content.replace("> Do not lose this MFA device. Recovering a root account without the MFA device is a lengthy, difficult process involving AWS Support and identity verification.", "> Do not lose this MFA device. Recovering a root account without the MFA device is a lengthy, difficult process involving AWS Support and identity verification." + p1_dummy)

# Part 3: GENERATE PROGRAMMATIC ACCESS KEYS
guide_content = guide_content.replace("### 🖥️ Method 1: AWS Management Console\n1. Navigate to your new `admin`", "1. Navigate to your new `admin`") # was missing? Actually wait, let's check what it has.
# Wait, I didn't add Method 1 to Part 3 earlier. Let's do it safely.
if "## 🔑 PART 3 — GENERATE PROGRAMMATIC ACCESS KEYS\n\nTo interact with AWS" in guide_content:
    guide_content = guide_content.replace(
        "## 🔑 PART 3 — GENERATE PROGRAMMATIC ACCESS KEYS\n\nTo interact with AWS via scripts, Terraform, or the CLI, our new IAM user needs cryptographic keys.\n\n1.", 
        "## 🔑 PART 3 — GENERATE PROGRAMMATIC ACCESS KEYS\n\nTo interact with AWS via scripts, Terraform, or the CLI, our new IAM user needs cryptographic keys.\n\n### 🖥️ Method 1: AWS Management Console\n1."
    )

p3_dummy = "\n\n### 🐧 Method 2: AWS CLI (Bash)\n*(This task requires initial UI access to generate the first set of keys and must be performed via the Management Console)*\n\n### 🪟 Method 3: AWS CLI (PowerShell)\n*(This task requires initial UI access to generate the first set of keys and must be performed via the Management Console)*"
guide_content = guide_content.replace("> This is the *only* time AWS will ever show you the Secret Access Key. If you lose it, you must generate a new key pair. Never commit this file to GitHub or share it publicly.", "> This is the *only* time AWS will ever show you the Secret Access Key. If you lose it, you must generate a new key pair. Never commit this file to GitHub or share it publicly." + p3_dummy)

# Part 4: CONFIGURE THE AWS CLI
# Currently has ### 🖥️ Method 1: Interactive AWS CLI Configuration
guide_content = guide_content.replace("### 🖥️ Method 1: Interactive AWS CLI Configuration", "### 🖥️ Method 1: AWS Management Console\n*(AWS CLI Configuration is a local terminal operation. See Methods 2 and 3)*\n\n### 🖥️ Method 1: Interactive AWS CLI Configuration") # wait, interactive CLI is local.
guide_content = guide_content.replace("### 🖥️ Method 1: Interactive AWS CLI Configuration\n1. Open your terminal.", "### 🖥️ Method 1: AWS Management Console\n*(AWS CLI Configuration is a local terminal operation. Run the interactive `aws configure` command locally as shown below)*\n\n1. Open your terminal.")
# Ensure Method 2 and 3 names match
guide_content = guide_content.replace("### 🐧 Method 2: Verify via Bash Script", "### 🐧 Method 2: AWS CLI (Bash)")
guide_content = guide_content.replace("### 🪟 Method 3: Verify via PowerShell Script", "### 🪟 Method 3: AWS CLI (PowerShell)")

# Part 6: CLEANUP
# Missing Console method
p6_console = "### 🖥️ Method 1: AWS Management Console\n1. Go to CloudWatch -> Alarms and delete AccountBillingAlarm.\n2. Go to SNS -> Topics and delete the billing-alerts topic.\n3. Go to IAM -> Users, delete access keys, and delete the user.\n4. Go to IAM -> User groups and delete the Administrators group.\n"
guide_content = guide_content.replace("## 🧹 PART 6 — CLEANUP\nTo avoid persistent charges or clutter, use these scripts", "## 🧹 PART 6 — CLEANUP\nTo avoid persistent charges or clutter, use these scripts\n\n" + p6_console)


with open(guide_path, 'w', encoding='utf-8') as f:
    f.write(guide_content)

print("Updated Project 1!")
