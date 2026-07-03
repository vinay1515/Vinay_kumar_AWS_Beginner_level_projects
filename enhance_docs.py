import os
import glob
import re

# List of all projects in order
PROJECTS = [
    "project-01-iam-setup",
    "project-02-s3-static-website",
    "project-03-Launch-EC2-Connect-via-SSH",
    "project-04-s3-versioning",
    "project-05-Custom-VPC",
    "project-06-rds-ec2",
    "project-07-cloudwatch-monitoring",
    "project-08-serverless-rest-api",
    "project-09-cicd-pipeline",
    "project-10-auto-scaling-alb",
    "project-11-infrastructure-as-code",
    "project-12-event-driven-pipeline"
]

# Rich Content Dictionary for 12 projects
PROJECT_DATA = {
    "project-01-iam-setup": {
        "title": "IAM Setup & Security",
        "level": "🟢 Beginner",
        "cost": "$0.00 (Free Tier)",
        "purpose": "Establish a secure, least-privilege cloud foundation protecting against credential theft.",
        "real_world": [
            "**Enterprise Onboarding:** Automatically provisioning developer accounts with scoped permissions.",
            "**Auditing:** Using IAM Access Analyzer to detect unused credentials in legacy accounts.",
            "**Compliance:** Enforcing MFA for all administrative actions to meet SOC2 requirements."
        ],
        "specs": [
            "**IAM Users:** 3 (Admin, Developer, Auditor)",
            "**IAM Groups:** 3 distinct logical groups",
            "**Policies:** Custom inline and AWS Managed (AdministratorAccess, ViewOnlyAccess)",
            "**Security:** Virtual MFA enforcement via policy"
        ],
        "folders": {
            "docs/": "Contains deep-dive markdown files for architecture and deployment.",
            "scripts/powershell/": "Windows automation scripts for provisioning.",
            "scripts/bash/": "Linux/Mac shell scripts for provisioning."
        }
    },
    "project-02-s3-static-website": {
        "title": "S3 Static Website",
        "level": "🟢 Beginner",
        "cost": "$0.00 (Free Tier)",
        "purpose": "Deploy an infinitely scalable, low-cost static web application without managing servers.",
        "real_world": [
            "**Marketing Sites:** Hosting high-traffic landing pages securely.",
            "**Documentation:** Serving static internal wikis (like MkDocs or Docusaurus).",
            "**Frontend Hosting:** Hosting React/Angular SPAs backed by API Gateway."
        ],
        "specs": [
            "**Storage Service:** Amazon S3 Standard",
            "**Access:** Public Read via Bucket Policy",
            "**Routing:** Index Document (index.html), Error Document (error.html)",
            "**Endpoint:** `<bucket-name>.s3-website-<region>.amazonaws.com`"
        ],
        "folders": {
            "website/": "Contains HTML, CSS, and JS static assets.",
            "docs/": "Deployment and troubleshooting documentation.",
            "scripts/": "Automation scripts for bucket creation and sync."
        }
    },
    "project-03-Launch-EC2-Connect-via-SSH": {
        "title": "EC2 Launch & SSH",
        "level": "🟢 Beginner",
        "cost": "$0.00 (Free Tier)",
        "purpose": "Provision virtual machines in the cloud and establish secure, encrypted remote shell access.",
        "real_world": [
            "**Legacy App Migration:** Lifting and shifting older monoliths that require OS-level access.",
            "**Bastion Hosts:** Creating secure jump-boxes for accessing private network resources.",
            "**Custom Workloads:** Running specific software that isn't supported by managed services (e.g., custom rendering engines)."
        ],
        "specs": [
            "**Instance Type:** t2.micro (1 vCPU, 1GB RAM)",
            "**OS:** Amazon Linux 2023",
            "**Security Group:** Port 22 (SSH) open to Specific IP only",
            "**Key Pair:** RSA 2048-bit (.pem/.ppk)"
        ],
        "folders": {
            "docs/": "SSH troubleshooting and connection guides.",
            "scripts/": "CLI scripts for EC2 provisioning and key management."
        }
    },
    "project-04-s3-versioning": {
        "title": "S3 Versioning & Lifecycle",
        "level": "🟡 Intermediate",
        "cost": "$0.00 (Free Tier)",
        "purpose": "Implement ransomware protection, accidental deletion recovery, and automated storage cost optimization.",
        "real_world": [
            "**Disaster Recovery:** Cross-Region Replication (CRR) maintaining a live backup in another continent.",
            "**Compliance:** Retaining immutable versions of financial logs for 7 years.",
            "**Cost Optimization:** Automatically archiving massive log files to Glacier after 30 days."
        ],
        "specs": [
            "**Source Region:** ap-south-1",
            "**Replica Region:** ap-south-2",
            "**Versioning:** Enabled on both buckets",
            "**Lifecycle Rule:** 30 Days -> Standard-IA, 90 Days -> Glacier Flexible Retrieval"
        ],
        "folders": {
            "docs/": "Lifecycle configuration and recovery guides.",
            "scripts/": "Scripts to generate data and verify replication."
        }
    },
    "project-05-Custom-VPC": {
        "title": "Custom VPC Architecture",
        "level": "🟡 Intermediate",
        "cost": "$0.00 (Free Tier)",
        "purpose": "Design a secure, isolated network boundary mimicking traditional enterprise data center architecture.",
        "real_world": [
            "**Database Isolation:** Keeping RDS databases completely off the public internet.",
            "**Enterprise Networking:** Connecting on-premise datacenters via Site-to-Site VPN or Direct Connect to private subnets.",
            "**Microservices:** Creating specific subnets for specific service tiers (Web, App, Data)."
        ],
        "specs": [
            "**VPC CIDR:** 10.0.0.0/16 (65,536 IPs)",
            "**Public Subnets:** 10.0.1.0/24 (AZ-a), 10.0.2.0/24 (AZ-b)",
            "**Private Subnets:** 10.0.3.0/24 (AZ-a), 10.0.4.0/24 (AZ-b)",
            "**Gateways:** Internet Gateway (IGW), NAT Gateway (Elastic IP)"
        ],
        "folders": {
            "docs/": "Subnet mapping and routing table documentation.",
            "scripts/": "Complex orchestration scripts for network provisioning."
        }
    },
    "project-06-rds-ec2": {
        "title": "RDS Database & EC2 App",
        "level": "🟡 Intermediate",
        "cost": "$0.00 (Free Tier)",
        "purpose": "Deploy a traditional 2-tier application architecture with a managed relational database and secure credential handling.",
        "real_world": [
            "**E-Commerce Platforms:** Running Magento or WooCommerce on EC2 backed by RDS MySQL.",
            "**Enterprise ERPs:** SAP or custom CRM systems relying on ACID-compliant databases.",
            "**Zero-Trust:** Storing DB passwords in Secrets Manager rather than plaintext config files."
        ],
        "specs": [
            "**Database:** Amazon RDS (MySQL 8.0), db.t3.micro",
            "**Compute:** Amazon EC2 (Amazon Linux 2023), t2.micro",
            "**Credentials:** AWS Secrets Manager integration via IAM Role",
            "**Network:** DB Subnet Group (Private), Security Group Chaining (Port 3306)"
        ],
        "folders": {
            "docs/": "Database connection and IAM role troubleshooting.",
            "scripts/": "Scripts to provision RDS, EC2, and Secrets Manager."
        }
    },
    "project-07-cloudwatch-monitoring": {
        "title": "CloudWatch & SNS Alerts",
        "level": "🟡 Intermediate",
        "cost": "$0.00 (Free Tier)",
        "purpose": "Establish robust observability, dashboarding, and proactive alerting for cloud infrastructure.",
        "real_world": [
            "**FinOps:** Alerting the finance team if daily AWS spend exceeds $1000.",
            "**SRE/Ops:** Paging on-call engineers via PagerDuty (via SNS) when CPU hits 90%.",
            "**Security Analytics:** Triggering alerts when CloudWatch Logs detect 'Failed SSH login' events."
        ],
        "specs": [
            "**Metrics Monitored:** CPUUtilization, EstimatedCharges, StatusCheckFailed",
            "**Alarms:** 5+ custom CloudWatch Alarms (Target Tracking & Static)",
            "**Notification:** Amazon SNS Topic (Email protocol)",
            "**Dashboards:** Unified CloudWatch Dashboard (Line & Number widgets)"
        ],
        "folders": {
            "docs/": "Alarm configurations and metric definitions.",
            "scripts/": "Scripts to trigger simulated CPU load and test alarms."
        }
    },
    "project-08-serverless-rest-api": {
        "title": "Serverless REST API",
        "level": "🟡 Intermediate",
        "cost": "$0.00 (Free Tier Forever)",
        "purpose": "Build highly scalable, zero-maintenance backend systems using modern serverless paradigms.",
        "real_world": [
            "**Mobile App Backends:** Handling millions of unpredictable API requests from iOS/Android apps.",
            "**IoT Data Ingestion:** Receiving sensor data globally and storing it in DynamoDB instantly.",
            "**Microservices:** Breaking down monolithic APIs into discrete, independently scalable Lambda functions."
        ],
        "specs": [
            "**API Gateway:** REST API, Lambda Proxy Integration, ANY Method, /{proxy+} route",
            "**Compute:** AWS Lambda (Python 3.12, 128MB Memory)",
            "**Database:** Amazon DynamoDB (On-Demand billing, PK: userId)",
            "**Security:** IAM Execution Role strictly scoped to single DynamoDB table"
        ],
        "folders": {
            "lambda/": "Python source code for the backend API logic.",
            "docs/": "API endpoints, CORS, and Lambda Proxy details.",
            "scripts/": "Packaging and deployment scripts for API Gateway."
        }
    },
    "project-09-cicd-pipeline": {
        "title": "CI/CD Pipeline (CodePipeline)",
        "level": "🟡 Intermediate",
        "cost": "$0.00 (Free Tier)",
        "purpose": "Automate software delivery by building a pipeline that compiles, tests, and deploys code on every git push.",
        "real_world": [
            "**Agile Engineering:** Allowing developers to deploy to staging multiple times a day effortlessly.",
            "**Automated Testing:** Rejecting builds that fail unit tests before they reach production.",
            "**Fleet Management:** Updating hundreds of EC2 instances simultaneously via CodeDeploy."
        ],
        "specs": [
            "**Source:** AWS CodeCommit (Private Git Repository)",
            "**Build:** AWS CodeBuild (Amazon Linux 2 image, buildspec.yml)",
            "**Deploy:** AWS CodeDeploy (In-place deployment, appspec.yml, EC2 tag targeting)",
            "**Orchestration:** AWS CodePipeline"
        ],
        "folders": {
            "application/": "Contains the web app source, buildspec.yml, and appspec.yml.",
            "docs/": "Pipeline stage configurations and IAM role details.",
            "scripts/": "Scripts to initialize CodeCommit and trigger deployments."
        }
    },
    "project-10-auto-scaling-alb": {
        "title": "Auto Scaling & ALB",
        "level": "🔴 Advanced",
        "cost": "$0.00 (Free Tier)",
        "purpose": "Design a self-healing, highly available web architecture capable of surviving instance and AZ failures.",
        "real_world": [
            "**Traffic Spikes:** Handling Black Friday e-commerce traffic surges automatically.",
            "**Self-Healing:** Automatically replacing servers that crash in the middle of the night.",
            "**High Availability:** Distributing traffic evenly across multiple physical datacenters (AZs)."
        ],
        "specs": [
            "**Load Balancer:** Application Load Balancer (ALB) - Internet facing, HTTP/80",
            "**Auto Scaling Group:** Target Tracking (CPU 50%), Min: 2, Max: 4, ELB Health Checks",
            "**Compute Blueprint:** Launch Template (Amazon Linux 2023, t2.micro, User Data Script)",
            "**Target Group:** HTTP/80, Path /"
        ],
        "folders": {
            "docs/": "Scaling policies, Target Group configuration, and failover guides.",
            "scripts/": "Scripts to simulate high traffic and instance failure."
        }
    },
    "project-11-infrastructure-as-code": {
        "title": "Infrastructure as Code (IaC)",
        "level": "🔴 Advanced",
        "cost": "$0.00 (Free Tier)",
        "purpose": "Convert manual console clicks into repeatable, version-controlled YAML templates for automated provisioning.",
        "real_world": [
            "**Multi-Region Deployment:** Copying a production environment from US to Europe in minutes.",
            "**Disaster Recovery:** Re-creating a destroyed VPC identically from version control.",
            "**Auditing:** Using CloudFormation Drift Detection to see if engineers made manual unauthorized changes."
        ],
        "specs": [
            "**Tooling:** AWS CloudFormation (YAML)",
            "**Resources Defined:** VPC, IGW, Subnets, Route Tables, SG, LaunchTemplate, ASG, ALB",
            "**Features Used:** Parameters, Outputs, Mappings, !Ref, !GetAtt, !Sub",
            "**Operations:** Create Stack, Change Sets, Stack Rollback"
        ],
        "folders": {
            "templates/": "Contains the CloudFormation YAML declarative code.",
            "docs/": "Template syntax guides and drift detection instructions.",
            "scripts/": "CLI scripts for deploying and updating stacks via Change Sets."
        }
    },
    "project-12-event-driven-pipeline": {
        "title": "Event-Driven Data Pipeline",
        "level": "🔴 Advanced",
        "cost": "$0.00 (Free Tier)",
        "purpose": "Build an asynchronous, decoupled architecture where actions (S3 uploads) trigger downstream processing (SQS, Lambda).",
        "real_world": [
            "**Image Processing:** Automatically generating thumbnails when a user uploads a profile picture.",
            "**Order Processing:** Placing customer orders into an SQS queue to handle database throttling during peaks.",
            "**Log Analytics:** Streaming logs into S3, triggering Lambda to transform and push to OpenSearch."
        ],
        "specs": [
            "**Event Source:** Amazon S3 (s3:ObjectCreated:* events)",
            "**Queueing:** Amazon SQS (Standard Queue, Dead Letter Queue configured)",
            "**Compute:** AWS Lambda (Event Source Mapping to SQS, Batch Size 10)",
            "**Notification:** Amazon SNS (For processing failures/alerts)"
        ],
        "folders": {
            "lambda/": "Python logic for reading and acknowledging SQS messages.",
            "docs/": "Event tracing, queue configuration, and decoupled architecture guides.",
            "scripts/": "Scripts to upload test data and monitor the queue."
        }
    }
}


# Templates

NAV_TEMPLATE = """
<div align="center" style="margin: 30px 0; padding: 15px; border: 1px solid #e1e4e8; border-radius: 8px; background-color: #f6f8fa;">
  <table style="width: 100%; text-align: center; border: none; background: transparent;">
    <tr style="border: none;">
      <td style="width: 33%; border: none;">{prev_link}</td>
      <td style="width: 33%; border: none;"><a href="{home_link}" style="font-size: 16px; text-decoration: none;">🏠 <b>Project Home</b></a></td>
      <td style="width: 33%; border: none;">{next_link}</td>
    </tr>
  </table>
</div>
"""

def generate_svg_header(title, subtitle):
    # A beautiful interactive SVG header
    return f"""
<div align="center">
  <svg width="800" height="150" xmlns="http://www.w3.org/2000/svg">
    <style>
      .bg {{ fill: url(#grad); stroke: #e1e4e8; stroke-width: 2px; rx: 12px; }}
      .title {{ font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; font-size: 28px; font-weight: 800; fill: #ffffff; }}
      .subtitle {{ font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; font-size: 16px; font-weight: 500; fill: #e1e4e8; }}
      .glow {{ animation: pulse 3s infinite alternate; }}
      @keyframes pulse {{
        0% {{ opacity: 0.8; filter: drop-shadow(0 0 4px rgba(255,153,0,0.4)); }}
        100% {{ opacity: 1; filter: drop-shadow(0 0 12px rgba(255,153,0,0.9)); }}
      }}
      @media (prefers-color-scheme: dark) {{
        .bg {{ stroke: #30363d; }}
      }}
    </style>
    <defs>
      <linearGradient id="grad" x1="0%" y1="0%" x2="100%" y2="100%">
        <stop offset="0%" style="stop-color:#232f3e;stop-opacity:1" />
        <stop offset="100%" style="stop-color:#ff9900;stop-opacity:1" />
      </linearGradient>
    </defs>
    <rect width="100%" height="100%" class="bg" />
    <text x="50%" y="45%" dominant-baseline="middle" text-anchor="middle" class="title glow">{title}</text>
    <text x="50%" y="70%" dominant-baseline="middle" text-anchor="middle" class="subtitle">{subtitle}</text>
  </svg>
</div>
"""

def generate_readme_content(proj_id, proj_data, nav_html, current_readme):
    # Extract existing SVG architecture line
    arch_match = re.search(r'<img src="architecture/architecture.svg".*?/>', current_readme)
    arch_html = arch_match.group(0) if arch_match else '<img src="architecture/architecture.svg" alt="Project Architecture" width="800"/>'

    svg_header = generate_svg_header(proj_data["title"], proj_data["purpose"])

    specs_list = "\n".join([f"- {s}" for s in proj_data["specs"]])
    rw_list = "\n".join([f"- {r}" for r in proj_data["real_world"]])
    
    folders_html = ""
    for folder, desc in proj_data["folders"].items():
        folders_html += f"| `👉 {folder}` | {desc} |\n"

    new_content = f"""{svg_header}

{nav_html}

<div align="center">
  {arch_html}
</div>

---

## 🌟 Expansive Overview
> **Core Purpose:** {proj_data['purpose']}

{proj_data['title']} is designed to reflect enterprise-grade cloud engineering. This project moves beyond the console basics, demonstrating how AWS services are stitched together to form resilient, scalable, and highly available architectures.

### 💼 Real-World Usage Scenarios
Companies around the globe use this exact architectural pattern for:
{rw_list}

---

## ⚙️ Infrastructure Specifications

<details>
<summary><b>💡 Click to Expand Technical Specifications</b></summary>
<br>

| Component | Specification |
|-----------|---------------|
"""
    for spec in proj_data["specs"]:
        parts = spec.split(":")
        if len(parts) >= 2:
            key = parts[0].replace("**", "").strip()
            val = ":".join(parts[1:]).strip()
            new_content += f"| **{key}** | {val} |\n"
    
    new_content += """
</details>

---

## 📂 Project Structure & Performance

To optimize your execution of this project, adhere strictly to the following folder topology. 

| Directory | Core Function |
|-----------|---------------|
"""
    new_content += folders_html
    
    new_content += """
---

## 📚 Granular Documentation Suite
We have broken down the technical manuals into granular, highly detailed Markdown files. Start with the Project Overview and proceed sequentially:

- 📄 [Project Overview](docs/project-overview.md)
- 🏗️ [Architecture Details](docs/architecture.md)
- 🚀 [Deployment Guide](docs/deployment-guide.md)
- 🔐 [Security Protocols](docs/security-protocols.md)
- 🧪 [Testing Procedures](docs/testing-procedures.md)
- 🛠️ [Troubleshooting](docs/troubleshooting.md)
- 🧹 [Cleanup Guide](docs/cleanup-guide.md)

---
*✨ Modernized & Enhanced for the AWS Hands-On Portfolio ✨*
"""
    return new_content


def generate_doc_file(doc_type, proj_id, proj_data, nav_html, current_content):
    # Enhance the current content with SVG header, Navigation, and styling
    # We map doc_type to a friendly title
    titles = {
        "project-overview.md": "Expansive Project Overview",
        "architecture.md": "Granular Architecture Details",
        "deployment-guide.md": "Step-by-Step Deployment Guide",
        "security-protocols.md": "Advanced Security Protocols",
        "testing-procedures.md": "Rigorous Testing Procedures",
        "troubleshooting.md": "Expert Troubleshooting",
        "cleanup-guide.md": "Infrastructure Cleanup Guide"
    }
    
    title = titles.get(doc_type, doc_type)
    svg_header = generate_svg_header(f"{proj_data['title']}", title)
    
    # Strip existing markdown H1 if present
    content_lines = current_content.split("\n")
    if content_lines and content_lines[0].startswith("# "):
        content_lines = content_lines[1:]
    
    clean_content = "\n".join(content_lines).strip()
    
    # Strip any old navigation blocks if we are re-running
    clean_content = re.sub(r'<div align="center" style="margin: 30px 0;.*?</svg>\n</div>', '', clean_content, flags=re.DOTALL)
    
    new_content = f"""{svg_header}

{nav_html}

<br>

<div style="background-color: #fdfdfe; border-left: 4px solid #ff9900; padding: 15px; border-radius: 4px; box-shadow: 0 2px 4px rgba(0,0,0,0.05);">
  <i>The following granular documentation is designed to provide enterprise-level clarity for deploying and managing this AWS architecture. Pay close attention to the architectural specifications and step-by-step methodologies below.</i>
</div>

<br>

{clean_content}

<br>

{nav_html}
"""
    return new_content


def main():
    base_dir = "e:/AWS Hands-on Projects"
    
    for i, proj in enumerate(PROJECTS):
        proj_dir = os.path.join(base_dir, proj)
        if not os.path.isdir(proj_dir):
            continue
            
        print(f"Enhancing {proj}...")
        
        # Calculate Navigation Links
        prev_link = "<i>(First Project)</i>"
        if i > 0:
            prev_proj = PROJECTS[i-1]
            prev_link = f"<a href='../{prev_proj}/README.md' style='font-size: 16px; text-decoration: none;'>⏪ <b>Previous: {prev_proj.split('-', 2)[-1].title().replace('-', ' ')}</b></a>"
            
        next_link = "<i>(Final Project)</i>"
        if i < len(PROJECTS) - 1:
            next_proj = PROJECTS[i+1]
            next_link = f"<a href='../{next_proj}/README.md' style='font-size: 16px; text-decoration: none;'><b>Next: {next_proj.split('-', 2)[-1].title().replace('-', ' ')}</b> ⏩</a>"
            
        readme_nav = NAV_TEMPLATE.format(prev_link=prev_link, home_link="README.md", next_link=next_link)
        docs_nav = NAV_TEMPLATE.format(
            prev_link=prev_link.replace("../", "../../"), 
            home_link="../README.md", 
            next_link=next_link.replace("../", "../../")
        )
        
        proj_data = PROJECT_DATA[proj]
        
        # 1. Update README.md
        readme_path = os.path.join(proj_dir, "README.md")
        if os.path.exists(readme_path):
            with open(readme_path, "r", encoding="utf-8") as f:
                current_readme = f.read()
            new_readme = generate_readme_content(proj, proj_data, readme_nav, current_readme)
            with open(readme_path, "w", encoding="utf-8") as f:
                f.write(new_readme)
                
        # 2. Update Docs files
        docs_dir = os.path.join(proj_dir, "docs")
        if os.path.exists(docs_dir):
            for doc_name in os.listdir(docs_dir):
                if not doc_name.endswith(".md"):
                    continue
                doc_path = os.path.join(docs_dir, doc_name)
                with open(doc_path, "r", encoding="utf-8") as f:
                    current_doc = f.read()
                new_doc = generate_doc_file(doc_name, proj, proj_data, docs_nav, current_doc)
                with open(doc_path, "w", encoding="utf-8") as f:
                    f.write(new_doc)

    print("✅ All projects enhanced successfully!")

if __name__ == "__main__":
    main()
