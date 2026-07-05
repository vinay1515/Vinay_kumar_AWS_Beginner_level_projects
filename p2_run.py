import os
import re

base = r"e:\AWS Hands-on Projects\project-02-s3-static-website"

# 1. Split deploy.sh and deploy.ps1 into 01..04 scripts
bash_dir = os.path.join(base, "scripts", "bash")
ps_dir = os.path.join(base, "scripts", "powershell")

def write_script(dir_path, name, content):
    with open(os.path.join(dir_path, name), 'w', encoding='utf-8') as f:
        f.write(content)

b_01 = """#!/bin/bash
source ../../.env
aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$AWS_REGION"
"""
b_02 = """#!/bin/bash
source ../../.env
aws s3api put-bucket-website --bucket "$BUCKET_NAME" --website-configuration '{"IndexDocument": {"Suffix": "index.html"},"ErrorDocument": {"Key": "error.html"}}'
"""
b_03 = """#!/bin/bash
source ../../.env
aws s3api put-public-access-block --bucket "$BUCKET_NAME" --public-access-block-configuration "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"
aws s3api put-bucket-policy --bucket "$BUCKET_NAME" --policy '{"Version":"2012-10-17","Statement":[{"Sid":"PublicReadGetObject","Effect":"Allow","Principal":"*","Action":"s3:GetObject","Resource":"arn:aws:s3:::'"$BUCKET_NAME"'/*"}]}'
"""
b_04 = """#!/bin/bash
source ../../.env
aws s3 sync ../../website/ s3://"$BUCKET_NAME"/ --region "$AWS_REGION"
"""

p_01 = """$BUCKET_NAME = (Get-Content ..\\..\\.env | Where-Object { $_ -match '^BUCKET_NAME=' } | ForEach-Object { $_ -replace '^BUCKET_NAME=','' })
$AWS_REGION = (Get-Content ..\\..\\.env | Where-Object { $_ -match '^AWS_REGION=' } | ForEach-Object { $_ -replace '^AWS_REGION=','' })
aws s3api create-bucket --bucket $BUCKET_NAME --region $AWS_REGION
"""
p_02 = """$BUCKET_NAME = (Get-Content ..\\..\\.env | Where-Object { $_ -match '^BUCKET_NAME=' } | ForEach-Object { $_ -replace '^BUCKET_NAME=','' })
aws s3api put-bucket-website --bucket $BUCKET_NAME --website-configuration '{"IndexDocument": {"Suffix": "index.html"},"ErrorDocument": {"Key": "error.html"}}'
"""
p_03 = """$BUCKET_NAME = (Get-Content ..\\..\\.env | Where-Object { $_ -match '^BUCKET_NAME=' } | ForEach-Object { $_ -replace '^BUCKET_NAME=','' })
aws s3api put-public-access-block --bucket $BUCKET_NAME --public-access-block-configuration "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"
aws s3api put-bucket-policy --bucket $BUCKET_NAME --policy "{\\`"Version\\`":\\`"2012-10-17\\`",\\`"Statement\\`":[{\\`"Sid\\`":\\`"PublicReadGetObject\\`",\\`"Effect\\`":\\`"Allow\\`",\\`"Principal\\`":\\`"*\\`",\\`"Action\\`":\\`"s3:GetObject\\`",\\`"Resource\\`":\\`"arn:aws:s3:::$BUCKET_NAME/*\\`"}]}"
"""
p_04 = """$BUCKET_NAME = (Get-Content ..\\..\\.env | Where-Object { $_ -match '^BUCKET_NAME=' } | ForEach-Object { $_ -replace '^BUCKET_NAME=','' })
$AWS_REGION = (Get-Content ..\\..\\.env | Where-Object { $_ -match '^AWS_REGION=' } | ForEach-Object { $_ -replace '^AWS_REGION=','' })
aws s3 sync ..\\..\\website\\ s3://$BUCKET_NAME/ --region $AWS_REGION
"""

write_script(bash_dir, "01-create-bucket.sh", b_01)
write_script(bash_dir, "02-enable-hosting.sh", b_02)
write_script(bash_dir, "03-apply-policy.sh", b_03)
write_script(bash_dir, "04-deploy-code.sh", b_04)

write_script(ps_dir, "01-create-bucket.ps1", p_01)
write_script(ps_dir, "02-enable-hosting.ps1", p_02)
write_script(ps_dir, "03-apply-policy.ps1", p_03)
write_script(ps_dir, "04-deploy-code.ps1", p_04)

try:
    os.remove(os.path.join(bash_dir, "deploy.sh"))
    os.remove(os.path.join(ps_dir, "deploy.ps1"))
except:
    pass

# 2. Update README.md
readme_path = os.path.join(base, "README.md")
with open(readme_path, 'r', encoding='utf-8') as f:
    readme_content = f.read()

new_table = """| Step | Bash Script | PowerShell Script | Description |
|------|-------------|-------------------|-------------|
| 01 | `scripts/bash/01-create-bucket.sh` | `scripts/powershell/01-create-bucket.ps1` | Creates the initial S3 bucket |
| 02 | `scripts/bash/02-enable-hosting.sh` | `scripts/powershell/02-enable-hosting.ps1` | Enables static website hosting |
| 03 | `scripts/bash/03-apply-policy.sh` | `scripts/powershell/03-apply-policy.ps1` | Applies public read bucket policy |
| 04 | `scripts/bash/04-deploy-code.sh` | `scripts/powershell/04-deploy-code.ps1` | Uploads HTML/CSS files to S3 |
| 05 | `scripts/bash/invalidate_cache.sh` | `scripts/powershell/invalidate_cache.ps1` | Forces CloudFront to pull new files |

### 📸 Screenshots & Validation
Throughout the documentation and `images/` directory, you will find screenshots captured during the deployment process. These visual artifacts serve as verification that the UI steps were successfully executed and validate the final architecture."""

readme_content = re.sub(r'<table>[\s\S]*?</table>', new_table, readme_content)

with open(readme_path, 'w', encoding='utf-8') as f:
    f.write(readme_content)

# 3. Update docs/deployment-guide.md
guide_path = os.path.join(base, "docs", "deployment-guide.md")
with open(guide_path, 'r', encoding='utf-8') as f:
    guide_content = f.read()

# Since we completely mangled this with `p2_refactor.py` previously, let's just strip out Part 6 (Fully Automated Deployment) and interleave the scripts into Parts 1-4.
guide_content = re.sub(r'## 🤖 PART 6 — FULLY AUTOMATED DEPLOYMENT \(Alternative\)[\s\S]*?(?=## ⚡ PART 7)', '', guide_content)

def inject_methods(content, part_header, bash_script, ps_script):
    match = re.search(part_header + r'(.*?)### 🖥️ Method 1: AWS Management Console\s*\n([\s\S]*?)(?=\n---)', content, re.DOTALL)
    if not match: return content
    new_text = match.group(0)
    new_text += f"\n\n### 🐧 Method 2: AWS CLI (Bash)\n```bash\n{bash_script}\n```"
    new_text += f"\n\n### 🪟 Method 3: AWS CLI (PowerShell)\n```powershell\n{ps_script}\n```"
    return content.replace(match.group(0), new_text)

guide_content = inject_methods(guide_content, r'## 🏗️ PART 1 — PROVISION THE S3 BUCKET\s*\n', b_01, p_01)
guide_content = inject_methods(guide_content, r'## ⚙️ PART 2 — ENABLE STATIC WEBSITE HOSTING\s*\n', b_02, p_02)
guide_content = inject_methods(guide_content, r'## 🔐 PART 3 — APPLY THE PUBLIC BUCKET POLICY\s*\n', b_03, p_03)


p4_new = """## 🚀 PART 4 — DEPLOY THE WEBSITE CODE

We will use the AWS CLI to rapidly sync a local directory of code to the S3 bucket.

### 🖥️ Method 1: AWS Management Console
1. Navigate to your bucket.
2. Click **Upload**.
3. Click **Add files** and select your `index.html` and `style.css`.
4. Click **Upload**.

### 🐧 Method 2: AWS CLI (Bash)
```bash
""" + b_04 + """
```

### 🪟 Method 3: AWS CLI (PowerShell)
```powershell
""" + p_04 + """
```"""

# Use simple string replacement for p4
p4_idx = guide_content.find('## 🚀 PART 4 — DEPLOY THE WEBSITE CODE')
p4_end_idx = guide_content.find('---', p4_idx)
guide_content = guide_content[:p4_idx] + p4_new + "\n\n" + guide_content[p4_end_idx:]


# Part 5: Validation - add dummy methods
p5_new = """## 🌐 PART 5 — VALIDATE THE LIVE WEBSITE

### 🖥️ Method 1: AWS Management Console
1. Open your web browser.
2. Paste the **Bucket website endpoint URL** you copied in Part 2.
3. You should see the custom HTML portfolio page rendered perfectly in your browser!

### 🐧 Method 2: AWS CLI (Bash)
*(Validation is a visual check in the browser. See Method 1)*

### 🪟 Method 3: AWS CLI (PowerShell)
*(Validation is a visual check in the browser. See Method 1)*"""
p5_idx = guide_content.find('## 🌐 PART 5 — VALIDATE THE LIVE WEBSITE')
p5_end_idx = guide_content.find('---', p5_idx)
guide_content = guide_content[:p5_idx] + p5_new + "\n\n" + guide_content[p5_end_idx:]

# Fix Part 8 Cleanup to have Console Method 1.
p8_console = """### 🖥️ Method 1: AWS Management Console
1. Go to S3.
2. Select your bucket and click **Empty**. Confirm by typing the bucket name.
3. Select your bucket again and click **Delete**. Confirm by typing the bucket name.
"""
guide_content = guide_content.replace("## 🧹 PART 8 — CLEANUP\nUse these scripts to empty and delete the bucket to stop incurring storage costs.", "## 🧹 PART 8 — CLEANUP\nUse these scripts to empty and delete the bucket to stop incurring storage costs.\n\n" + p8_console)
# Shift Method 1 to Method 2 etc in Part 8 and 7.
guide_content = guide_content.replace("PART 7 — INVALIDATE CLOUDFRONT CACHE (Optional)\nIf you attach CloudFront to this bucket in the future, use these scripts to force a cache refresh when you upload new code.\n\n### 🐧 Method 1: AWS CLI (Bash)", "PART 7 — INVALIDATE CLOUDFRONT CACHE (Optional)\nIf you attach CloudFront to this bucket in the future, use these scripts to force a cache refresh when you upload new code.\n\n### 🖥️ Method 1: AWS Management Console\n*(CloudFront invalidation can be done via CloudFront -> Invalidations -> Create Invalidation in the UI)*\n\n### 🐧 Method 2: AWS CLI (Bash)")
guide_content = guide_content.replace("### 🪟 Method 2: AWS CLI (PowerShell)", "### 🪟 Method 3: AWS CLI (PowerShell)")

with open(guide_path, 'w', encoding='utf-8') as f:
    f.write(guide_content)

print("Updated Project 2!")
