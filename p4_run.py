import os
import re

base = r"e:\AWS Hands-on Projects\project-04-s3-versioning"

# 1. Update README.md
readme_path = os.path.join(base, "README.md")
with open(readme_path, 'r', encoding='utf-8') as f:
    readme_content = f.read()

new_table = """| Step | Bash Script | PowerShell Script | Description |
|------|-------------|-------------------|-------------|
| 01 | `scripts/bash/01-create-source-bucket.sh` | `scripts/powershell/01-create-source-bucket.ps1` | Creates the source bucket with versioning |
| 02 | `scripts/bash/02-test-versioning.sh` | `scripts/powershell/02-test-versioning.ps1` | Demonstrates overwrite, restore, and delete marker operations |
| 03 | `scripts/bash/03-create-lifecycle-policy.sh` | `scripts/powershell/03-create-lifecycle-policy.ps1` | Applies cost-optimization lifecycle rules |
| 04 | `scripts/bash/04-cross-region-replication.sh` | `scripts/powershell/04-cross-region-replication.ps1` | Sets up IAM roles, destination bucket, and CRR rules |
| 05 | `scripts/bash/05-test-replication.sh` | `scripts/powershell/05-test-replication.ps1` | Validates replication across regions |
| 06 | `scripts/bash/06-cleanup.sh` | `scripts/powershell/06-cleanup.ps1` | Permanently destroys buckets and versions |

### 📸 Screenshots & Validation
Throughout the documentation and `images/` directory, you will find screenshots captured during the deployment process. These visual artifacts serve as verification that the UI steps were successfully executed and validate the final architecture."""

readme_content = re.sub(r'<table>[\s\S]*?</table>', new_table, readme_content)

with open(readme_path, 'w', encoding='utf-8') as f:
    f.write(readme_content)

# 2. Update docs/deployment-guide.md
guide_path = os.path.join(base, "docs", "deployment-guide.md")
with open(guide_path, 'r', encoding='utf-8') as f:
    guide_content = f.read()

# Part 2 Workflow: add dummy method 1
p2_console = """### 🖥️ Method 1: AWS Management Console
1. Upload `document.txt` to the bucket.
2. Modify `document.txt` locally and upload it again.
3. In the bucket UI, toggle **Show versions** to see both versions.
4. Delete the current version.
5. In the versions list, select the **Delete marker** and delete it to restore the file.
"""
guide_content = guide_content.replace(
    "This phase demonstrates how Versioning protects you from catastrophic data loss.\n\n### 🐧 Method 1: AWS CLI (Bash)",
    "This phase demonstrates how Versioning protects you from catastrophic data loss.\n\n" + p2_console + "\n### 🐧 Method 2: AWS CLI (Bash)"
)
guide_content = guide_content.replace("### 🪟 Method 2: AWS CLI (PowerShell)", "### 🪟 Method 3: AWS CLI (PowerShell)")

# Part 6 Cleanup: Add Console steps
p6_console = """### 🖥️ Method 1: AWS Management Console
1. Go to **S3**.
2. Select your source bucket and click **Empty**. Type the bucket name to confirm.
3. Select the source bucket and click **Delete**.
4. Repeat the Empty and Delete steps for the replica bucket in us-west-2.
5. Go to **IAM** -> **Roles**, search for your replication role, and delete it.
"""
guide_content = guide_content.replace(
    "## 🧹 PART 6 — PROPER INFRASTRUCTURE TEARDOWN\nTo prevent recurring AWS charges, proceed to the `docs/cleanup-guide.md` to run the tear-down scripts. Versioned buckets require a specialized deletion loop to destroy underlying versions before the bucket can be removed.\n\n### 🐧 Method 1: AWS CLI (Bash)",
    "## 🧹 PART 6 — PROPER INFRASTRUCTURE TEARDOWN\nTo prevent recurring AWS charges, proceed to the `docs/cleanup-guide.md` to run the tear-down scripts. Versioned buckets require a specialized deletion loop to destroy underlying versions before the bucket can be removed.\n\n" + p6_console + "\n### 🐧 Method 2: AWS CLI (Bash)"
)
# We already replaced '### 🪟 Method 2: AWS CLI (PowerShell)' -> '### 🪟 Method 3...' globally?
# No, let's fix the specific occurrences.
# We used replace above. Wait, if there were two occurrences of Method 2, they both got replaced.
# Let's check `p4_refactor.py` logic. It originally output Method 2 for Powershell in P2 and P6.
# If I just do a global replace for those, it will fix both!

with open(guide_path, 'w', encoding='utf-8') as f:
    f.write(guide_content)

print("Updated Project 4!")
