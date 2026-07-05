import os
import re

base_dir = r"e:\AWS Hands-on Projects"

def read_file(path):
    with open(path, "r", encoding="utf-8") as f:
        return f.read()

def write_file(path, content):
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)

# Fix P4 Part 6
print("Fixing P4 Part 6...")
p4_guide = os.path.join(base_dir, "project-04-s3-versioning", "docs", "deployment-guide.md")
c4 = read_file(p4_guide)

# Replace "### 🖥️ Method 1: AWS Management Console\n```bash" with proper headers
old_p4_str = "### 🖥️ Method 1: AWS Management Console\n```bash"
new_p4_str = """### 🖥️ Method 1: AWS Management Console
1. Go to the S3 console and delete all object versions from the source bucket.
2. Delete the source bucket.
3. Empty and delete the destination bucket.
4. Go to IAM and delete the replication role.

### 🐧 Method 2: AWS CLI (Bash)
```bash"""
if old_p4_str in c4:
    c4 = c4.replace(old_p4_str, new_p4_str)
write_file(p4_guide, c4)

# Fix P5 Part 8
print("Fixing P5 Part 8...")
p5_guide = os.path.join(base_dir, "project-05-Custom-VPC", "docs", "deployment-guide.md")
c5 = read_file(p5_guide)

# We want to find PART 8 and replace its content until the end of file or next ---
def fix_p5(m):
    body = m.group(1)
    new_body = """### 🖥️ Method 1: AWS Management Console
*(Connectivity testing is performed via terminal. See Methods 2 and 3).*

### 🐧 Method 2: AWS CLI (Bash)
""" + body.strip() + """

### 🪟 Method 3: AWS CLI (PowerShell)
*(Follow the exact same SSH test procedures listed in Method 2)*

"""
    return "## 🌐 PART 8 — VERIFY CONNECTIVITY\n\n" + new_body

c5 = re.sub(r'## 🌐 PART 8 — VERIFY CONNECTIVITY\n\n(.*?)(?=---|$)', fix_p5, c5, flags=re.DOTALL)
write_file(p5_guide, c5)

print("Done")
