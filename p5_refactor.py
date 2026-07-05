import os
import re

base = r"e:\AWS Hands-on Projects\project-05-Custom-VPC"
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

content = content.replace('### Console Steps', '### 🖥️ Method 1: AWS Management Console')

def replace_first(content, search, replacement):
    idx = content.find(search)
    if idx == -1:
        # try without extra newlines just in case
        search2 = "### CLI Steps\n```powershell"
        idx = content.find(search2)
        if idx == -1: return content
        search = search2
    return content[:idx] + replacement + content[idx + len(search):]

search_str = "### CLI Steps\n\n```powershell"

# PART 1: VPC
bash_script = read_script('01-create-vpc.sh', 'bash')
p1_replacement = "### 🐧 Method 2: AWS CLI (Bash)\n```bash\n" + bash_script + "\n```\n\n### 🪟 Method 3: AWS CLI (PowerShell)\n```powershell"
content = replace_first(content, search_str, p1_replacement)

# PART 2: SUBNETS
p2_replacement = "### 🐧 Method 2: AWS CLI (Bash)\n*(Included in 01-create-vpc.sh above)*\n\n### 🪟 Method 3: AWS CLI (PowerShell)\n```powershell"
content = replace_first(content, search_str, p2_replacement)

# PART 3: IGW
p3_replacement = "### 🐧 Method 2: AWS CLI (Bash)\n*(Included in 02-create-route-tables.sh below)*\n\n### 🪟 Method 3: AWS CLI (PowerShell)\n```powershell"
content = replace_first(content, search_str, p3_replacement)

# PART 4: ROUTE TABLES
bash_script = read_script('02-create-route-tables.sh', 'bash')
p4_replacement = "### 🐧 Method 2: AWS CLI (Bash)\n```bash\n" + bash_script + "\n```\n\n### 🪟 Method 3: AWS CLI (PowerShell)\n```powershell"
content = replace_first(content, search_str, p4_replacement)

# PART 5: NAT GATEWAY
bash_script = read_script('03-create-nat-gateway.sh', 'bash')
p5_replacement = "### 🐧 Method 2: AWS CLI (Bash)\n```bash\n" + bash_script + "\n```\n\n### 🪟 Method 3: AWS CLI (PowerShell)\n```powershell"
content = replace_first(content, search_str, p5_replacement)

# PART 6: SECURITY GROUPS
bash_script = read_script('04-create-security-groups.sh', 'bash')
p6_replacement = "### 🐧 Method 2: AWS CLI (Bash)\n```bash\n" + bash_script + "\n```\n\n### 🪟 Method 3: AWS CLI (PowerShell)\n```powershell"
content = replace_first(content, search_str, p6_replacement)

# PART 7: TEST EC2
bash_script = read_script('05-launch-instances.sh', 'bash')
p7_replacement = "### 🐧 Method 2: AWS CLI (Bash)\n```bash\n" + bash_script + "\n```\n\n### 🪟 Method 3: AWS CLI (PowerShell)\n```powershell"
content = replace_first(content, search_str, p7_replacement)

# PART 9: CLEANUP
cleanup_bash = read_script('06-cleanup.sh', 'bash')
p9_match = re.search(r'(## 🧹 PART 9 — CLEANUP\s*\n\s*Run in this exact order — dependencies matter:\s*\n\s*)(```powershell[\s\S]*?```)([\s\S]*?)$', content)
if p9_match:
    new_p9 = p9_match.group(1) + "### 🐧 Method 1: AWS CLI (Bash)\n```bash\n" + cleanup_bash + "\n```\n\n### 🪟 Method 2: AWS CLI (PowerShell)\n" + p9_match.group(2) + p9_match.group(3)
    content = content.replace(p9_match.group(0), new_p9)


with open(guide_path, 'w', encoding='utf-8') as f:
    f.write(content)
print("Updated Project 5!")
