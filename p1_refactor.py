import os
import re

base = r"e:\AWS Hands-on Projects\project-01-iam-setup"
guide_path = os.path.join(base, "docs", "deployment-guide.md")

with open(guide_path, 'r', encoding='utf-8') as f:
    content = f.read()

def read_script(name, kind):
    path = os.path.join(base, "scripts", kind, name)
    try:
        with open(path, 'r', encoding='utf-8') as f:
            return f.read().strip()
    except:
        return ""

# We will replace sections based on regex or exact splits.

# PART 2 — ESTABLISH IAM ADMINISTRATOR AND RBAC
# It has a "### Console Execution" block.
# We want to change "### Console Execution" to "### 🖥️ Method 1: AWS Management Console"
# And then append the bash and powershell scripts at the end of that section.

p2_console = re.search(r'(## 🏗️ PART 2 — ESTABLISH IAM ADMINISTRATOR AND RBAC\s*\n\s*)### Console Execution([\s\S]*?)(?=\n---\n)', content)
if p2_console:
    bash_script = read_script('setup-iam-user.sh', 'bash')
    ps1_script = read_script('setup-iam-user.ps1', 'powershell')
    
    new_p2 = p2_console.group(1) + "### 🖥️ Method 1: AWS Management Console" + p2_console.group(2)
    if bash_script:
        new_p2 += "\n\n### 🐧 Method 2: AWS CLI (Bash)\n```bash\n" + bash_script + "\n```"
    if ps1_script:
        new_p2 += "\n\n### 🪟 Method 3: AWS CLI (PowerShell)\n```powershell\n" + ps1_script + "\n```"
        
    content = content.replace(p2_console.group(0), new_p2)

# PART 4 — CONFIGURE THE AWS CLI
# Has "### Local Execution (PowerShell or Bash)"
p4_console = re.search(r'(## 🌍 PART 4 — CONFIGURE THE AWS CLI\s*\n\s*)(.*?)### Local Execution \(PowerShell or Bash\)([\s\S]*?)(?=\n---\n)', content, re.DOTALL)
if p4_console:
    bash_script = read_script('verify_setup.sh', 'bash')
    ps1_script = read_script('verify_setup.ps1', 'powershell')
    
    new_p4 = p4_console.group(1) + p4_console.group(2) + "### 🖥️ Method 1: Interactive AWS CLI Configuration\n" + p4_console.group(3)
    if bash_script:
        new_p4 += "\n\n### 🐧 Method 2: Verify via Bash Script\n```bash\n" + bash_script + "\n```"
    if ps1_script:
        new_p4 += "\n\n### 🪟 Method 3: Verify via PowerShell Script\n```powershell\n" + ps1_script + "\n```"
        
    content = content.replace(p4_console.group(0), new_p4)

# PART 5 — DEPLOY FINANCIAL GUARDRAILS (AWS BUDGETS)
p5_console = re.search(r'(## 💰 PART 5 — DEPLOY FINANCIAL GUARDRAILS \(AWS BUDGETS\)\s*\n\s*)(.*?)### Console Execution([\s\S]*?)$', content, re.DOTALL)
if p5_console:
    bash_script = read_script('setup-billing-alarm.sh', 'bash')
    ps1_script = read_script('setup-billing-alarm.ps1', 'powershell')
    cleanup_bash = read_script('cleanup.sh', 'bash')
    cleanup_ps1 = read_script('cleanup.ps1', 'powershell')
    
    new_p5 = p5_console.group(1) + p5_console.group(2) + "### 🖥️ Method 1: AWS Management Console\n" + p5_console.group(3)
    if bash_script:
        new_p5 += "\n\n### 🐧 Method 2: AWS CLI (Bash)\n```bash\n" + bash_script + "\n```"
    if ps1_script:
        new_p5 += "\n\n### 🪟 Method 3: AWS CLI (PowerShell)\n```powershell\n" + ps1_script + "\n```"
        
    new_p5 += "\n\n---\n\n## 🧹 PART 6 — CLEANUP\n"
    new_p5 += "To avoid persistent charges or clutter, use these scripts to tear down the resources (if you are not proceeding to the next projects).\n"
    if cleanup_bash:
        new_p5 += "\n### 🐧 Method 1: AWS CLI (Bash)\n```bash\n" + cleanup_bash + "\n```"
    if cleanup_ps1:
        new_p5 += "\n\n### 🪟 Method 2: AWS CLI (PowerShell)\n```powershell\n" + cleanup_ps1 + "\n```\n"

    content = content.replace(p5_console.group(0), new_p5)

# Also rename PART 1 Console Execution
content = content.replace('### Console Execution\n1. Log into the', '### 🖥️ Method 1: AWS Management Console\n1. Log into the')
content = content.replace('### Console Execution\n1. In the AWS Console', '### 🖥️ Method 1: AWS Management Console\n1. In the AWS Console')

with open(guide_path, 'w', encoding='utf-8') as f:
    f.write(content)
print("Updated Project 1!")
