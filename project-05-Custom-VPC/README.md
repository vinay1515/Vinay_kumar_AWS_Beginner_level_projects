# Project 5: Custom VPC

## Introduction
Build a production-grade AWS network from absolute scratch, similar to what real companies use to isolate and
secure their cloud infrastructure.

This project is designed to be intermediate in difficulty, with an estimated time of 4-5 hours. It covers topics
such as understanding VPCs, subnets, internet gateways, route tables, NAT gateways, EC2 instances, network ACLs,
and security groups.

## Learning Objectives
- Understand what a VPC is and why it exists.
- Create public and private subnets across two Availability Zones.
- Attach an Internet Gateway for public internet access.
- Configure route tables to control traffic flow.
- Deploy a NAT Gateway so private instances can reach the internet.
- Understand the difference between public and private subnets.
- Launch EC2 instances in both subnet types and verify connectivity.
- Understand Network ACLs vs Security Groups.

## AWS Services Used
- **VPC**: Your private isolated network in AWS.
- **Subnets**: Subdivisions of the VPC — public and private.
- **Internet Gateway (IGW)**: Connects your VPC to the public internet.
- **Route Tables**: Rules that control where network traffic goes.
- **NAT Gateway**: Lets private instances reach the internet without being reachable from it.
- **Elastic IP**: Static public IP address — required for NAT Gateway.
- **Security Groups**: Instance-level virtual firewall (stateful).
- **Network ACL**: Subnet-level firewall (stateless).
- **EC2**: Test instances to verify connectivity.

## Architecture
```
┌─────────────────────────────────────────────────────────────────┐
│                    YOUR CUSTOM VPC                               │
│                    CIDR: 10.0.0.0/16                            │
│                    Region: us-east-1                            │
│                                                                 │
│  ┌──────────────────────────┐  ┌──────────────────────────┐    │
│  │  Availability Zone A     │  │  Availability Zone B     │    │
│  │  us-east-1a              │  │  us-east-1b              │    │
│  │                          │  │                          │    │
│  │  ┌────────────────────┐  │  │  ┌────────────────────┐  │    │
│  │  │  PUBLIC SUBNET A   │  │  │  │  PUBLIC SUBNET B   │  │    │
│  │  │  10.0.1.0/24       │  │  │  │  10.0.2.0/24       │  │    │
│  │  │                    │  │  │  │                    │  │    │
│  │  │  EC2 Bastion Host  │  │  │  │  (future: ALB)     │  │    │
│  │  │  Public IP ✅      │  │  │  │                    │  │    │
│  │  └────────────────────┘  │  │  └────────────────────┘  │    │
│  │                          │  │                          │    │
│  │  ┌────────────────────┐  │  │  ┌────────────────────┐  │    │
│  │  │  PRIVATE SUBNET A  │  │  │  │  PRIVATE SUBNET B  │  │    │
│  │  │  10.0.3.0/24       │  │  │  │  10.0.4.0/24       │  │    │
│  │  │                    │  │  │  │                    │  │    │
│  │  │  EC2 Private App   │  │  │  │  (future: RDS)     │  │    │
│  │  │  No Public IP ✅   │  │  │  │                    │  │    │
│  │  └────────────────────┘  │  │  └────────────────────┘  │    │
│  └──────────────────────────┘  └──────────────────────────┘    │
│                                                                 │
│  ┌─────────────────┐    ┌──────────────────────────────────┐   │
│  │ Internet Gateway│    │ NAT Gateway (in Public Subnet A) │   │
│  │ (IGW)           │    │ Elastic IP attached              │   │
│  └────────┬────────┘    └──────────────┬───────────────────┘   │
└───────────┼─────────────────────────────┼─────────────────────-┘
            │                             │
            ▼                             ▼
      Public Internet            Private instances
      (bidirectional)            can reach internet
                                 (outbound only)
```

## CIDR Block Plan
| Resource        | CIDR        | Notes |
|------------------|-------------|-------|
| VPC              | 10.0.0.0/16     | 65,536 IP addresses total |
| Public Subnet A   | 10.0.1.0/24      | 256 IPs — us-east-1a |
| Public Subnet B   | 10.0.2.0/24      | 256 IPs — us-east-1b |
| Private Subnet A   | 10.0.3.0/24      | 256 IPs — us-east-1a |
| Private Subnet B   | 10.0.4.0/24      | 256 IPs — us-east-1b |

### AWS Reserved IPs
AWS reserves 5 IPs per subnet (.0, .1, .2, .3, .255) in each /24 block to provide additional IP addresses for
other services.

## Cost Estimate
- **Best case (NAT Gateway deleted after testing):** ~$0.05
- **Worst case (NAT Gateway left running 1 hour):** ~$0.10

### Cleanup Steps
Deleting the NAT Gateway immediately after use is necessary to avoid incurring additional costs.

By following these steps, you will have a fully functional custom VPC setup for your project.