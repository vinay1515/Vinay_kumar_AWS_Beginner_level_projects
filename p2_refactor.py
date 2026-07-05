import os
import re

base = r"e:\AWS Hands-on Projects\project-02-s3-static-website"
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

# Update headers
content = content.replace('### Console Execution', '### 🖥️ Method 1: AWS Management Console')
content = content.replace('### Local Execution (PowerShell or Bash)', '### 🖥️ Method 1: Interactive AWS CLI')

# Append automated deployment, invalidation, and cleanup
deploy_bash = read_script('deploy.sh', 'bash')
deploy_ps1 = read_script('deploy.ps1', 'powershell')

inv_bash = read_script('invalidate_cache.sh', 'bash')
inv_ps1 = read_script('invalidate_cache.ps1', 'powershell')

cleanup_bash = read_script('cleanup.sh', 'bash')
cleanup_ps1 = read_script('cleanup.ps1', 'powershell')

new_sections = "\n\n---\n\n## 🤖 PART 6 — FULLY AUTOMATED DEPLOYMENT (Alternative)\n"
new_sections += "If you prefer to bypass the manual console steps (Parts 1-4), you can use these fully automated scripts that create the bucket, apply the policies, and upload the code in one shot.\n"
if deploy_bash:
    new_sections += "\n### 🐧 Method 2: AWS CLI (Bash)\n```bash\n" + deploy_bash + "\n```"
if deploy_ps1:
    new_sections += "\n\n### 🪟 Method 3: AWS CLI (PowerShell)\n```powershell\n" + deploy_ps1 + "\n```"

new_sections += "\n\n---\n\n## ⚡ PART 7 — INVALIDATE CLOUDFRONT CACHE (Optional)\n"
new_sections += "If you attach CloudFront to this bucket in the future, use these scripts to force a cache refresh when you upload new code.\n"
if inv_bash:
    new_sections += "\n### 🐧 Method 1: AWS CLI (Bash)\n```bash\n" + inv_bash + "\n```"
if inv_ps1:
    new_sections += "\n\n### 🪟 Method 2: AWS CLI (PowerShell)\n```powershell\n" + inv_ps1 + "\n```"

new_sections += "\n\n---\n\n## 🧹 PART 8 — CLEANUP\n"
new_sections += "Use these scripts to empty and delete the bucket to stop incurring storage costs.\n"
if cleanup_bash:
    new_sections += "\n### 🐧 Method 1: AWS CLI (Bash)\n```bash\n" + cleanup_bash + "\n```"
if cleanup_ps1:
    new_sections += "\n\n### 🪟 Method 2: AWS CLI (PowerShell)\n```powershell\n" + cleanup_ps1 + "\n```\n"

content += new_sections

with open(guide_path, 'w', encoding='utf-8') as f:
    f.write(content)
print("Updated Project 2!")
