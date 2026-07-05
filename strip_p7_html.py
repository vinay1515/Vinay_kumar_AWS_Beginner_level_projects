import os
import re

docs_dir = r"e:\AWS Hands-on Projects\project-07-cloudwatch-monitoring\docs"

# Regexes to match the HTML blocks
svg_block = r'<div align="center">\s*<svg.*?</svg>\s*</div>\s*'
nav_table = r'<div align="center"[^>]*>\s*<table.*?</table[^>]*>\s*</div>\s*'
disclaimer = r'<div style="background-color: #fdfdfe[^>]*>.*?</div>\s*'
br_tags = r'<br>\s*'

for filename in os.listdir(docs_dir):
    if not filename.endswith(".md"):
        continue
        
    path = os.path.join(docs_dir, filename)
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()
        
    # Strip the blocks
    content = re.sub(svg_block, '', content, flags=re.DOTALL)
    content = re.sub(nav_table, '', content, flags=re.DOTALL)
    content = re.sub(disclaimer, '', content, flags=re.DOTALL)
    content = re.sub(br_tags, '', content, flags=re.DOTALL)
    
    # Clean up leading newlines
    content = content.lstrip()
    
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)
        
    print(f"Stripped HTML from {filename}")

print("Done.")
