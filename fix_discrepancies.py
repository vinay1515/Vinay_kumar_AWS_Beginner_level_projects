import os
import re

base_dir = r"e:\AWS Hands-on Projects"

def read_file(path):
    with open(path, "r", encoding="utf-8") as f:
        return f.read()

def write_file(path, content):
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)

print("Fixing Project 1...")
p1_guide = os.path.join(base_dir, "project-01-iam-setup", "docs", "deployment-guide.md")
content = read_file(p1_guide)

# P1 Part 2
bash_path = os.path.join(base_dir, "project-01-iam-setup", "scripts", "bash", "setup-iam-user.sh")
ps_path = os.path.join(base_dir, "project-01-iam-setup", "scripts", "powershell", "setup-iam-user.ps1")
repl = lambda m: m.group(1) + "\n\n### 🐧 Method 2: AWS CLI (Bash)\n```bash\n" + read_file(bash_path).strip() + "\n```\n\n### 🪟 Method 3: AWS CLI (PowerShell)\n```powershell\n" + read_file(ps_path).strip() + "\n```\n\n"
content = re.sub(r'(## 🏗️ PART 2 — ESTABLISH IAM ADMINISTRATOR AND RBAC.*?)(?=---|$)', repl, content, flags=re.DOTALL)

# P1 Part 4 (Verify Setup)
bash_path = os.path.join(base_dir, "project-01-iam-setup", "scripts", "bash", "verify_setup.sh")
ps_path = os.path.join(base_dir, "project-01-iam-setup", "scripts", "powershell", "verify_setup.ps1")
repl = lambda m: "### 🐧 Method 2: AWS CLI (Bash)\n```bash\n" + read_file(bash_path).strip() + "\n```\n\n### 🪟 Method 3: AWS CLI (PowerShell)\n```powershell\n" + read_file(ps_path).strip() + "\n```\n\n"
content = re.sub(r'### 🐧 Method 2: AWS CLI \(Bash\).*?(?=---|$)', repl, content, flags=re.DOTALL)

# P1 Part 5 (Billing Alarm)
bash_path = os.path.join(base_dir, "project-01-iam-setup", "scripts", "bash", "setup-billing-alarm.sh")
ps_path = os.path.join(base_dir, "project-01-iam-setup", "scripts", "powershell", "setup-billing-alarm.ps1")
repl = lambda m: m.group(1) + "\n\n### 🐧 Method 2: AWS CLI (Bash)\n```bash\n" + read_file(bash_path).strip() + "\n```\n\n### 🪟 Method 3: AWS CLI (PowerShell)\n```powershell\n" + read_file(ps_path).strip() + "\n```\n\n"
content = re.sub(r'(## 💸 PART 5 — ENABLE BILLING ALERTS.*?)(?=---|$)', repl, content, flags=re.DOTALL)

# P1 Part 6 (Cleanup)
bash_path = os.path.join(base_dir, "project-01-iam-setup", "scripts", "bash", "cleanup.sh")
ps_path = os.path.join(base_dir, "project-01-iam-setup", "scripts", "powershell", "cleanup.ps1")
repl = lambda m: "### 🐧 Method 2: AWS CLI (Bash)\n```bash\n" + read_file(bash_path).strip() + "\n```\n\n### 🪟 Method 3: AWS CLI (PowerShell)\n```powershell\n" + read_file(ps_path).strip() + "\n```\n\n"
content = re.sub(r'### 🐧 Method 1: AWS CLI \(Bash\).*?$', repl, content, flags=re.DOTALL)
write_file(p1_guide, content)

print("Fixing Project 2...")
p2_guide = os.path.join(base_dir, "project-02-s3-static-website", "docs", "deployment-guide.md")
content = read_file(p2_guide)
content = content.replace("### 🖥️ Method 1: AWS CLI (Bash)", "### 🐧 Method 2: AWS CLI (Bash)")
content = content.replace("### 🐧 Method 1: AWS CLI (Bash)", "### 🐧 Method 2: AWS CLI (Bash)")
write_file(p2_guide, content)

print("Fixing Project 3...")
p3_guide = os.path.join(base_dir, "project-03-Launch-EC2-Connect-via-SSH", "docs", "deployment-guide.md")
content = read_file(p3_guide)
content = content.replace("### 🖥️ Method 1: Connect via EC2 Instance Connect (Browser)", "### 🖥️ Method 1: AWS Management Console")
content = content.replace("### 🐧 Method 2: Standard SSH (Mac/Linux)", "### 🐧 Method 2: AWS CLI (Bash)")
content = content.replace("### 🪟 Method 3: Connect via PowerShell/PuTTY (Windows)", "### 🪟 Method 3: AWS CLI (PowerShell)")
write_file(p3_guide, content)

print("Fixing Project 4...")
p4_guide = os.path.join(base_dir, "project-04-s3-versioning", "docs", "deployment-guide.md")
content = read_file(p4_guide)
content = content.replace("### 🖥️ Method 1: AWS Management Console (Verification)", "### 🖥️ Method 1: AWS Management Console")
content = content.replace("### 🪟 Method 2: AWS CLI (PowerShell)", "### 🪟 Method 3: AWS CLI (PowerShell)")
write_file(p4_guide, content)

print("Fixing Project 5...")
p5_guide = os.path.join(base_dir, "project-05-Custom-VPC", "docs", "deployment-guide.md")
content = read_file(p5_guide)
content = content.replace("### 🖥️ Method 1: EC2 Instance Connect (Console)", "### 🖥️ Method 1: AWS Management Console")
content = content.replace("### 🐧 Method 2: SSH from Local Terminal (Bash)", "### 🐧 Method 2: AWS CLI (Bash)")
content = content.replace("### 🪟 Method 3: SSH from Local Terminal (PowerShell)", "### 🪟 Method 3: AWS CLI (PowerShell)")
write_file(p5_guide, content)

print("Done fixing discrepancies.")
