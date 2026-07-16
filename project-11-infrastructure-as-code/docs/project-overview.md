# Project 11 Overview: Infrastructure as Code with CloudFormation

## 🎯 Business Problem

Historically, infrastructure was provisioned manually through the AWS Management Console or via imperative scripts. This approach leads to several critical issues:
- **Configuration Drift ("Snowflake" Servers):** Over time, manual changes make it impossible to know the exact state of the environment.
- **Lack of Version Control:** Infrastructure changes cannot be tracked, reviewed, or rolled back effectively like application code.
- **Difficult Replication:** Recreating a production environment for testing or disaster recovery is slow, error-prone, and relies on "tribal knowledge."
- **Orphaned Resources:** When tearing down manual deployments, resources are easily forgotten, leading to runaway costs and security vulnerabilities.

## 🚀 Solution

**Infrastructure as Code (IaC)** solves these problems by allowing you to define your cloud environment declaratively using code (YAML or JSON). 

In this project, we use **AWS CloudFormation** to provision the exact same highly available, auto-scaling web architecture from Project 10 (VPC + ALB + ASG), but this time entirely through code. 
- **Consistency:** The environment deploys identically every single time, in any region.
- **Safety:** Updates are previewed using **Change Sets** before applying, and failed deployments automatically trigger a **Rollback** to the last known-good state.
- **Auditable:** The template acts as the single source of truth and living documentation.
- **Clean Teardown:** A single command deletes the entire stack, ensuring no resources are left behind.

## 🏆 Learning Objectives

By completing this project, you will master the fundamentals of CloudFormation:
1. **Anatomy of a Template:** Write YAML templates using `Parameters`, `Mappings`, `Conditions`, `Resources`, and `Outputs`.
2. **Intrinsic Functions:** Utilize functions like `!Ref`, `!GetAtt`, `!Sub`, and `!Select` to dynamically link resources.
3. **Change Sets:** Safely preview and execute modifications to a running infrastructure stack.
4. **Rollbacks:** Understand CloudFormation's automatic safety mechanisms when an update or creation fails.
5. **Drift Detection:** Identify resources that have been manually modified outside of the CloudFormation stack.
6. **Stack Deletion:** Cleanly tear down a complex environment with a single command.

## 🛠️ AWS Services Used

| Service | Role in Architecture |
|:---|:---|
| **AWS CloudFormation** | The core IaC engine that parses the template and provisions resources in the correct dependency order. |
| **Amazon VPC** | Defined in code: VPC, Subnets, Internet Gateway, and Route Tables. |
| **Amazon EC2** | Defined in code: Launch Templates, Security Groups, and Auto Scaling Groups. |
| **Elastic Load Balancing** | Defined in code: Application Load Balancer, Listeners, and Target Groups. |
| **AWS IAM** | Execution roles and capabilities required by CloudFormation (`CAPABILITY_IAM`). |

## ✅ Free Tier Status

**CloudFormation itself is completely free**; you only pay for the underlying resources it provisions. Because this template recreates the Project 10 architecture, the cost footprint is identical.

| Resource | Cost |
|:---------|:-----|
| **AWS CloudFormation** | Always Free |
| **EC2 t2.micro** (2 instances) | Free Tier (750 hours/month) |
| **ALB** | ~$0.0225/hr + LCU (Not Free Tier) |
| **EBS & VPC** | Free / Included in Free Tier |

> [!WARNING]
> While CloudFormation is free, the ALB provisioned by the stack costs ~$16/month if left running. Always run the `delete-stack` command when you are finished testing to destroy all resources and stop charges immediately.

