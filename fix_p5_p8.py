import os

base_dir = r"e:\AWS Hands-on Projects"
p5_guide = os.path.join(base_dir, "project-05-Custom-VPC", "docs", "deployment-guide.md")

with open(p5_guide, "r", encoding="utf-8") as f:
    c5 = f.read()

# find "PART 8"
idx_start = c5.find("PART 8")
if idx_start != -1:
    # find the end of the line
    idx_line_end = c5.find("\n", idx_start)
    # find the next ---
    idx_end = c5.find("---", idx_line_end)
    if idx_end == -1:
        idx_end = len(c5)
        
    part_8_body = c5[idx_line_end:idx_end].strip()
    
    new_body = """
### 🖥️ Method 1: AWS Management Console
*(Connectivity testing is performed via terminal. See Methods 2 and 3).*

### 🐧 Method 2: AWS CLI (Bash)
""" + part_8_body + """

### 🪟 Method 3: AWS CLI (PowerShell)
*(Follow the exact same SSH test procedures listed in Method 2)*

"""
    
    c5 = c5[:idx_line_end] + "\n" + new_body + c5[idx_end:]
    
    with open(p5_guide, "w", encoding="utf-8") as f:
        f.write(c5)
    print("Fixed P5 Part 8 using index matching")
else:
    print("Could not find PART 8")
