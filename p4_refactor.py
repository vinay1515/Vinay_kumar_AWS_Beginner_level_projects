import os
import re

base = r"e:\AWS Hands-on Projects\project-04-s3-versioning"
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

def replace_part(content, regex_str, bash_script, ps1_script, console_tag="### 🖥️ Method 1: AWS Management Console"):
    match = re.search(regex_str, content, re.DOTALL)
    if not match: return content
    # If the section already has "Console Execution", we replace it. 
    # If not, we just prepend the console tag to the rest of the text.
    body = match.group(3)
    
    new_text = match.group(1) + match.group(2) + console_tag + "\n" + body
    if bash_script:
        new_text += "\n\n### 🐧 Method 2: AWS CLI (Bash)\n```bash\n" + bash_script + "\n```"
    if ps1_script:
        new_text += "\n\n### 🪟 Method 3: AWS CLI (PowerShell)\n```powershell\n" + ps1_script + "\n```"
    return content.replace(match.group(0), new_text)

# PART 1
content = replace_part(
    content, 
    r'(## 🏗️ PART 1 — PROVISION THE SOURCE BUCKET\s*\n\s*)(.*?)### Console Execution\s*\n([\s\S]*?)(?=\n---\n)',
    read_script('01-create-source-bucket.sh', 'bash'),
    read_script('01-create-source-bucket.ps1', 'powershell')
)

# PART 2 (No console execution, it's just steps)
p2_match = re.search(r'(## 🧪 PART 2 — THE VERSIONING WORKFLOW\s*\n\s*)([\s\S]*?)(?=\n---\n)', content, re.DOTALL)
if p2_match:
    bash_script = read_script('02-test-versioning.sh', 'bash')
    ps1_script = read_script('02-test-versioning.ps1', 'powershell')
    new_p2 = p2_match.group(1) + "This phase demonstrates how Versioning protects you from catastrophic data loss.\n"
    if bash_script:
        new_p2 += "\n### 🐧 Method 1: AWS CLI (Bash)\n```bash\n" + bash_script + "\n```"
    if ps1_script:
        new_p2 += "\n\n### 🪟 Method 2: AWS CLI (PowerShell)\n```powershell\n" + ps1_script + "\n```"
    content = content.replace(p2_match.group(0), new_p2)

# PART 3
content = replace_part(
    content, 
    r'(## 📉 PART 3 — ARCHITECTING LIFECYCLE POLICIES\s*\n\s*)(.*?)### Console Execution\s*\n([\s\S]*?)(?=\n---\n)',
    read_script('03-create-lifecycle-policy.sh', 'bash'),
    read_script('03-create-lifecycle-policy.ps1', 'powershell')
)

# PART 4 (No "Console Execution" header)
p4_match = re.search(r'(## 🌍 PART 4 — CONFIGURING CROSS-REGION REPLICATION \(CRR\)\s*\n\s*)(For Disaster Recovery .*?\.)\s*\n([\s\S]*?)(?=\n---\n)', content, re.DOTALL)
if p4_match:
    bash_script = read_script('04-cross-region-replication.sh', 'bash')
    ps1_script = read_script('04-cross-region-replication.ps1', 'powershell')
    
    new_p4 = p4_match.group(1) + p4_match.group(2) + "\n\n### 🖥️ Method 1: AWS Management Console\n" + p4_match.group(3)
    if bash_script:
        new_p4 += "\n\n### 🐧 Method 2: AWS CLI (Bash)\n```bash\n" + bash_script + "\n```"
    if ps1_script:
        new_p4 += "\n\n### 🪟 Method 3: AWS CLI (PowerShell)\n```powershell\n" + ps1_script + "\n```"
    content = content.replace(p4_match.group(0), new_p4)


# PART 5 (No "Console Execution" header)
p5_match = re.search(r'(## 🔍 PART 5 — VALIDATE REPLICATION SLA\s*\n\s*)(1\. Upload a new test file[\s\S]*?)(?=\n---\n)', content, re.DOTALL)
if p5_match:
    bash_script = read_script('05-test-replication.sh', 'bash')
    ps1_script = read_script('05-test-replication.ps1', 'powershell')
    
    new_p5 = p5_match.group(1) + "### 🖥️ Method 1: Interactive/Manual validation\n" + p5_match.group(2)
    if bash_script:
        new_p5 += "\n\n### 🐧 Method 2: AWS CLI (Bash)\n```bash\n" + bash_script + "\n```"
    if ps1_script:
        new_p5 += "\n\n### 🪟 Method 3: AWS CLI (PowerShell)\n```powershell\n" + ps1_script + "\n```"
    content = content.replace(p5_match.group(0), new_p5)


# ADD CLEANUP
cleanup_bash = read_script('06-cleanup.sh', 'bash')
cleanup_ps1 = read_script('06-cleanup.ps1', 'powershell')

# PART 6
p6_match = re.search(r'(## 🧹 PART 6 — PROPER INFRASTRUCTURE TEARDOWN\s*\n\s*)([\s\S]*?)$', content, re.DOTALL)
if p6_match:
    new_p6 = p6_match.group(1) + p6_match.group(2)
    if cleanup_bash:
        new_p6 += "\n\n### 🐧 Method 1: AWS CLI (Bash)\n```bash\n" + cleanup_bash + "\n```"
    if cleanup_ps1:
        new_p6 += "\n\n### 🪟 Method 2: AWS CLI (PowerShell)\n```powershell\n" + cleanup_ps1 + "\n```\n"
    content = content.replace(p6_match.group(0), new_p6)

with open(guide_path, 'w', encoding='utf-8') as f:
    f.write(content)
print("Updated Project 4!")
