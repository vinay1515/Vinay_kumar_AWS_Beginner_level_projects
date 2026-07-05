import os
import re

base = r"e:\AWS Hands-on Projects\project-03-Launch-EC2-Connect-via-SSH"
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

def replace_part(content, regex_str, bash_script, ps1_script):
    match = re.search(regex_str, content, re.DOTALL)
    if not match: return content
    new_text = match.group(1) + match.group(2) + "### 🖥️ Method 1: AWS Management Console\n" + match.group(3)
    if bash_script:
        new_text += "\n\n### 🐧 Method 2: AWS CLI (Bash)\n```bash\n" + bash_script + "\n```"
    if ps1_script:
        new_text += "\n\n### 🪟 Method 3: AWS CLI (PowerShell)\n```powershell\n" + ps1_script + "\n```"
    return content.replace(match.group(0), new_text)

# PART 1
content = replace_part(
    content, 
    r'(## 🔑 PART 1 — GENERATE THE SSH KEY PAIR\s*\n\s*)(.*?)### Console Execution([\s\S]*?)(?=\n---\n)',
    read_script('01-create-key-pair.sh', 'bash'),
    read_script('01-create-key-pair.ps1', 'powershell')
)

# PART 2
content = replace_part(
    content, 
    r'(## 🛡️ PART 2 — CONFIGURE THE SECURITY GROUP \(FIREWALL\)\s*\n\s*)(.*?)### Console Execution([\s\S]*?)(?=\n---\n)',
    read_script('02-create-security-group.sh', 'bash'),
    read_script('02-create-security-group.ps1', 'powershell')
)

# PART 3
content = replace_part(
    content, 
    r'(## 🏗️ PART 3 — LAUNCH THE EC2 INSTANCE\s*\n\s*)(.*?)### Console Execution([\s\S]*?)(?=\n---\n)',
    read_script('03-launch-instance.sh', 'bash'),
    read_script('03-launch-instance.ps1', 'powershell')
)

# PART 5 is a bit different
p5_match = re.search(r'(## 💻 PART 5 — CONNECT VIA SSH \(TERMINAL\)\s*\n\s*)(.*?)(### For Windows 10/11, Mac, or Linux \(Using built-in SSH client\)[\s\S]*?)$', content, re.DOTALL)
if p5_match:
    bash_script = read_script('04-connect-ssm.sh', 'bash')
    ps1_script = read_script('04-connect-ssm.ps1', 'powershell')
    
    new_p5 = p5_match.group(1) + p5_match.group(2) + "### 🖥️ Method 1: Standard SSH\n" + p5_match.group(3).replace("### For Windows 10/11, Mac, or Linux (Using built-in SSH client)", "")
    
    new_p5 += "\n\n### 🐧 Method 2: AWS Systems Manager (SSM) via Bash\n```bash\n" + bash_script + "\n```"
    new_p5 += "\n\n### 🪟 Method 3: AWS Systems Manager (SSM) via PowerShell\n```powershell\n" + ps1_script + "\n```"
    
    content = content.replace(p5_match.group(0), new_p5)

# ADD CLEANUP
cleanup_bash = read_script('05-cleanup.sh', 'bash')
cleanup_ps1 = read_script('05-cleanup.ps1', 'powershell')

content += "\n\n---\n\n## 🧹 PART 6 — CLEANUP\n"
if cleanup_bash:
    content += "\n### 🐧 Method 1: AWS CLI (Bash)\n```bash\n" + cleanup_bash + "\n```"
if cleanup_ps1:
    content += "\n\n### 🪟 Method 2: AWS CLI (PowerShell)\n```powershell\n" + cleanup_ps1 + "\n```\n"

with open(guide_path, 'w', encoding='utf-8') as f:
    f.write(content)
print("Updated Project 3!")
