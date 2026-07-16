# Project Structure Template

This repository follows a strict structural template for all projects (01–14). To ensure consistency across the entire portfolio, any new projects or modifications must adhere to this standard.

## 📁 Directory Structure

```text
project-NN-name/
├── .env.example              # Environment variable template
├── .gitignore                # Standard AWS .gitignore
├── LICENSE                   # MIT License
├── README.md                 # Master guide (standard sections in exact order)
├── architecture/
│   └── *.svg                 # Architecture diagrams (SVG format preferred)
├── docs/
│   ├── project-overview.md   # CORE: Business problem, solution, learning objectives
│   ├── architecture.md       # CORE: System diagram, data flow, security architecture
│   ├── deployment-guide.md   # CORE: Step-by-step Console + CLI deployment
│   ├── security-protocols.md # CORE: IAM, network, encryption, compliance
│   ├── testing-procedures.md # CORE: Functional, security, performance tests
│   ├── troubleshooting.md    # CORE: Symptom/Cause/Fix format
│   ├── cleanup-guide.md      # CORE: Resource table + Console + Bash + PowerShell
│   └── [topic-specific].md   # OPTIONAL: Deep-dive docs relevant to the project
├── images/
│   └── NN-descriptive-name.png  # Sequential screenshots with descriptive names
└── scripts/
    ├── bash/
    │   └── NN-script-name.sh
    └── powershell/
        └── NN-script-name.ps1
```

## 📄 Core Document Templates

### README.md
The `README.md` is the entry point for the project and must follow this exact sequence:

1. **Header Block:** AWS logo (`width="36" height="36"`), H1 title, description, and status badges.
2. **Architecture Overview:** Embedded SVG diagram (use forward slashes for paths: `./architecture/diagram.svg`).
3. **Infrastructure Specifications:** Table detailing regions, instance types, etc.
4. **Key Components:** H3 subheadings for each major AWS service used.
5. **Core Features:** Bullet list highlighting design decisions (e.g., HA, encryption).
6. **Free Tier Status:** Mandatory table outlining the cost of each resource used.
7. **Setup & Installation:** Prerequisites, Pre-flight Checks (PowerShell), Installation (`cp .env.example .env`), and the Run Commands execution table.
8. **Documentation Suite:** Table linking to files in `docs/` with descriptive emojis.
9. **Contribution & Maintenance:** Testing, deployment, contributing guidelines.
10. **License:** Link explicitly to `./LICENSE` (the project-local MIT license).
11. **Footer:** Prev/Next project navigation block.

### Cleanup Guide (`docs/cleanup-guide.md`)
Must include the following sections:
- `> [!CAUTION]` block warning of irreversible action
- `## 📋 Resources to Delete` (Table showing resource, service, and deletion order rationale)
- `## 🖥️ Method 1: AWS Management Console` (Numbered steps)
- `## 🐧 Method 2: AWS CLI (Bash)` (Full script embedded inline)
- `## 🪟 Method 3: AWS CLI (PowerShell)` (Full script embedded inline)
- `## ✅ Cleanup Verification` (CLI commands to verify deletion)
- `## 💰 Cost Implications` (Details on what charges stop)

### Troubleshooting Guide (`docs/troubleshooting.md`)
Must use a structured approach for errors rather than just a dump of commands:
- Categorized sections (e.g., `## Network Errors`, `## Authentication Errors`)
- Under each section, list errors with: **Symptom**, **Cause**, and **Fix**.
- Provide a `## 📋 Quick Reference Table` mapping Problem to Quick Fix.
- Provide a `## 🔍 Debug Commands` section with useful CLI probing commands.

### Security Protocols (`docs/security-protocols.md`)
Must address the security posture of the deployed architecture:
- `## 🔐 IAM & Access Control` (Instance profiles, service-linked roles, resource policies)
- `## 🛡️ Network Security` (Security group chaining, VPC isolation)
- `## 🔒 Encryption` (Data at rest via KMS, data in transit via TLS)
- `## 📋 Compliance & Best Practices` (Audit logging, IMDSv2, least privilege)

## 🎨 Design System

When writing markdown for these projects, utilize these specific design elements:

1. **GitHub Alerts:** Use `> [!NOTE]`, `> [!TIP]`, `> [!WARNING]`, `> [!CAUTION]`, and `> [!IMPORTANT]` to highlight crucial information visually.
2. **Collapsible Sections:** Use `<details><summary>Title</summary>Content</details>` for verbose outputs, large JSON policies, or deep-dive asides that would otherwise clutter the main reading flow.
3. **Emoji Symbology:** Consistent use of emojis helps visual parsing.
   - 🏗️ Architecture
   - 🛠️ Setup / Configuration
   - 🧹 Cleanup
   - 🔐 Security
   - 🧪 Testing / Validation
   - ⚠️ Warnings / Cost Implications
