import os
import re

base_dir = r"e:\AWS Hands-on Projects"

def read_file(path):
    with open(path, "r", encoding="utf-8") as f:
        return f.read()

def write_file(path, content):
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)

# Fix P3
print("Fixing P3...")
p3_guide = os.path.join(base_dir, "project-03-Launch-EC2-Connect-via-SSH", "docs", "deployment-guide.md")
c3 = read_file(p3_guide)
c3 = re.sub(r'### \S+ Method 1: .*?\n', '### 🖥️ Method 1: AWS Management Console\n', c3)
c3 = re.sub(r'### \S+ Method 2: .*?\n', '### 🐧 Method 2: AWS CLI (Bash)\n', c3)
c3 = re.sub(r'### \S+ Method 3: .*?\n', '### 🪟 Method 3: AWS CLI (PowerShell)\n', c3)
write_file(p3_guide, c3)

# Fix P4
print("Fixing P4...")
p4_guide = os.path.join(base_dir, "project-04-s3-versioning", "docs", "deployment-guide.md")
c4 = read_file(p4_guide)
c4 = re.sub(r'### \S+ Method 1: .*?\n', '### 🖥️ Method 1: AWS Management Console\n', c4)
c4 = re.sub(r'### \S+ Method 2: .*?\n', '### 🐧 Method 2: AWS CLI (Bash)\n', c4)
c4 = re.sub(r'### \S+ Method 3: .*?\n', '### 🪟 Method 3: AWS CLI (PowerShell)\n', c4)
write_file(p4_guide, c4)

# Fix P5
print("Fixing P5...")
p5_guide = os.path.join(base_dir, "project-05-Custom-VPC", "docs", "deployment-guide.md")
c5 = read_file(p5_guide)
c5 = re.sub(r'### \S+ Method 1: .*?\n', '### 🖥️ Method 1: AWS Management Console\n', c5)
c5 = re.sub(r'### \S+ Method 2: .*?\n', '### 🐧 Method 2: AWS CLI (Bash)\n', c5)
c5 = re.sub(r'### \S+ Method 3: .*?\n', '### 🪟 Method 3: AWS CLI (PowerShell)\n', c5)
write_file(p5_guide, c5)

print("Done")
