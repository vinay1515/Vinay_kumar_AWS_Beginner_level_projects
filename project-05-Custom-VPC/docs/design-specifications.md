# Design Specifications

This document details the complete design specifications for the Custom VPC architecture, including CIDR planning, routing design, security group architecture, and NAT gateway configuration.

## 🌐 CIDR Block Plan

| Resource | CIDR | Usable IPs | Purpose |
|:---|:---|:---:|:---|
| **VPC** | `10.0.0.0/16` | 65,531 | Entire private address space |
| **Public Subnet A** | `10.0.1.0/24` | 251 | AZ-a: Bastion host, NAT Gateway |
| **Public Subnet B** | `10.0.2.0/24` | 251 | AZ-b: Future public resources |
| **Private Subnet A** | `10.0.3.0/24` | 251 | AZ-a: Application servers |
| **Private Subnet B** | `10.0.4.0/24` | 251 | AZ-b: Database servers |

> [!NOTE]
> AWS reserves 5 IP addresses in each subnet (first 4 + last 1): network address, VPC router, DNS, future use, and broadcast. A `/24` subnet provides 251 usable IPs, not 256.

## 🛤️ Routing Design

### Public Route Table
| Destination | Target | Purpose |
|:---|:---|:---|
| `10.0.0.0/16` | Local | VPC-internal routing |
| `0.0.0.0/0` | Internet Gateway | Internet access for public subnets |

### Private Route Table
| Destination | Target | Purpose |
|:---|:---|:---|
| `10.0.0.0/16` | Local | VPC-internal routing |
| `0.0.0.0/0` | NAT Gateway | Outbound-only internet for private subnets |

> [!IMPORTANT]
> Private subnets route through the NAT Gateway, which lives in the **public** subnet. This ensures private instances can download packages and updates without being directly accessible from the internet.

## 🔐 Security Group Design

### bastion-sg (Bastion Host)
| Direction | Port | Protocol | Source | Purpose |
|:---|:---:|:---|:---|:---|
| Inbound | 22 | TCP | My IP /32 | SSH from admin's PC only |
| Outbound | All | All | 0.0.0.0/0 | Default allow all |

### private-sg (Private Instances)
| Direction | Port | Protocol | Source | Purpose |
|:---|:---:|:---|:---|:---|
| Inbound | 22 | TCP | bastion-sg | SSH from bastion only |
| Outbound | All | All | 0.0.0.0/0 | Default allow all |

> [!TIP]
> **Security group chaining:** `private-sg` references `bastion-sg` as the source — not an IP range. This means only instances attached to `bastion-sg` can SSH into private instances. This is the **production bastion host pattern.**

### Why Security Group Chaining Matters
```text
Direct IP Reference (❌ Fragile):
  Rule: Allow SSH from 10.0.1.50/32
  Problem: If bastion IP changes, rule breaks

Security Group Reference (✅ Resilient):
  Rule: Allow SSH from sg-bastion
  Benefit: Any instance with bastion-sg can connect,
           regardless of its private IP
```

## 🌐 NAT Gateway Design

### Architecture
```text
Private Instance → Private Subnet Route Table → NAT Gateway (Public Subnet)
                                                       ↓
                                                Internet Gateway → Internet
```

### Key Design Decisions

| Decision | Choice | Rationale |
|:---|:---|:---|
| **NAT type** | NAT Gateway (managed) | Higher availability than NAT Instance; no OS patching |
| **Placement** | Public Subnet A | Must be in a public subnet with an Elastic IP |
| **High Availability** | Single AZ | Cost optimization for learning; production should use one NAT per AZ |
| **Elastic IP** | Allocated and associated | NAT Gateway requires a static public IP |

### Cost Consideration
> [!WARNING]
> **NAT Gateway costs ~$0.045/hour (~$32/month)** plus $0.045/GB data processed. This is the most expensive component in this project. **Delete it immediately after testing** using the cleanup scripts.

## 🏗️ Internet Gateway Design

The Internet Gateway (IGW) serves dual purposes:
1. **Outbound:** Provides internet access for instances in public subnets
2. **Inbound:** Enables SSH connections to the bastion host from your PC

### IGW vs. NAT Gateway

| Feature | Internet Gateway | NAT Gateway |
|:---|:---|:---|
| **Direction** | Bidirectional | Outbound only |
| **Cost** | Free | ~$0.045/hr |
| **Use case** | Public subnets | Private subnets |
| **Public IP required** | Yes (on instance) | Yes (Elastic IP on NAT) |
| **HA** | Built-in (AWS managed) | Per-AZ deployment |

## 📐 Subnet Sizing Strategy

For this project, we use `/24` subnets (251 usable IPs each). In production:

| Workload | Recommended Size | Usable IPs |
|:---|:---|:---:|
| Small application (≤50 instances) | `/24` | 251 |
| Medium application (≤250 instances) | `/23` | 507 |
| Large application (≤1000 instances) | `/22` | 1,019 |
| Micro-services with many ENIs | `/21` | 2,043 |

> [!TIP]
> Always oversize your subnets. You cannot resize a subnet after creation — you must delete and recreate it. Plan for 3x your expected capacity.
