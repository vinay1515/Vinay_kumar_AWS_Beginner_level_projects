<div align="center">
  <img src="architecture/architecture.svg" alt="Project Architecture" width="800"/>

  # Infrastructure as Code (Project 11)
  
  **Automate cloud provisioning using AWS CloudFormation templates.**
</div>

---

## 📋 Project Overview
This project introduces Infrastructure as Code (IaC). You will recreate the architecture from Project 10 (VPC, EC2, ALB, ASG), but this time, it will be provisioned entirely through a declarative AWS CloudFormation YAML template. This ensures environments are repeatable, version-controlled, and instantly deployable.

- **Level:** 🔴 Advanced
- **Time to Complete:** 3 hours
- **Cost Estimate:** ~$0.00 (Standard Free Tier applies)

## 🏗️ Architecture Flow
1. **CloudFormation Template:** A single YAML file (`main-stack.yaml`) containing parameters, resources, mappings, and outputs.
2. **Stack Deployment:** CloudFormation calculates dependencies and provisions the VPC, Subnets, Security Groups, Launch Template, ASG, and ALB in the correct order.
3. **Change Sets & Drift:** Modify the template and execute a change set to safely update running infrastructure. Detect manual changes using Drift Detection.

## 📚 Documentation
- 📄 [Project Overview](docs/project-overview.md)
- 🏗️ [Architecture Details](docs/architecture.md)
- 🚀 [Deployment Guide](docs/deployment-guide.md)
- 🔐 [Security Protocols](docs/security-protocols.md)
- 🧪 [Testing Procedures](docs/testing-procedures.md)
- 🛠️ [Troubleshooting](docs/troubleshooting.md)
- 🧹 [Cleanup Guide](docs/cleanup-guide.md)

## 💻 Automation Scripts
This project contains ready-to-run automation scripts for both **PowerShell** and **Bash**.
- **Windows:** `scripts/powershell/`
- **Linux/Mac:** `scripts/bash/`

---
*Generated as part of the AWS Hands-On Portfolio.*
