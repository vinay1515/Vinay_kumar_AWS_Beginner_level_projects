
<div align="center">
  <svg width="800" height="150" xmlns="http://www.w3.org/2000/svg">
    <style>
      .bg { fill: url(#grad); stroke: #e1e4e8; stroke-width: 2px; rx: 12px; }
      .title { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; font-size: 28px; font-weight: 800; fill: #ffffff; }
      .subtitle { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; font-size: 16px; font-weight: 500; fill: #e1e4e8; }
      .glow { animation: pulse 3s infinite alternate; }
      @keyframes pulse {
        0% { opacity: 0.8; filter: drop-shadow(0 0 4px rgba(255,153,0,0.4)); }
        100% { opacity: 1; filter: drop-shadow(0 0 12px rgba(255,153,0,0.9)); }
      }
      @media (prefers-color-scheme: dark) {
        .bg { stroke: #30363d; }
      }
    </style>
    <defs>
      <linearGradient id="grad" x1="0%" y1="0%" x2="100%" y2="100%">
        <stop offset="0%" style="stop-color:#232f3e;stop-opacity:1" />
        <stop offset="100%" style="stop-color:#ff9900;stop-opacity:1" />
      </linearGradient>
    </defs>
    <rect width="100%" height="100%" class="bg" />
    <text x="50%" y="45%" dominant-baseline="middle" text-anchor="middle" class="title glow">Custom VPC Architecture</text>
    <text x="50%" y="70%" dominant-baseline="middle" text-anchor="middle" class="subtitle">security-group-notes.md</text>
  </svg>
</div>



<div align="center" style="margin: 30px 0; padding: 15px; border: 1px solid #e1e4e8; border-radius: 8px; background-color: #f6f8fa;">
  <table style="width: 100%; text-align: center; border: none; background: transparent;">
    <tr style="border: none;">
      <td style="width: 33%; border: none;"><a href='../../project-04-s3-versioning/README.md' style='font-size: 16px; text-decoration: none;'>⏪ <b>Previous: S3 Versioning</b></a></td>
      <td style="width: 33%; border: none;"><a href="../README.md" style="font-size: 16px; text-decoration: none;">🏠 <b>Project Home</b></a></td>
      <td style="width: 33%; border: none;"><a href='../../project-06-rds-ec2/README.md' style='font-size: 16px; text-decoration: none;'><b>Next: Rds Ec2</b> ⏩</a></td>
    </tr>
  </table>
</div>


<br>

<div style="background-color: #fdfdfe; border-left: 4px solid #ff9900; padding: 15px; border-radius: 4px; box-shadow: 0 2px 4px rgba(0,0,0,0.05);">
  <i>The following granular documentation is designed to provide enterprise-level clarity for deploying and managing this AWS architecture. Pay close attention to the architectural specifications and step-by-step methodologies below.</i>
</div>

<br>

## Security Groups Created in This Project

### 1. bastion-sg

| Field | Value |
|---|---|
| Name | bastion-sg |
| VPC | my-custom-vpc |
| Purpose | Controls access to the bastion host (jump box) |

**Inbound Rules:**
| Rule # | Type | Protocol | Port | Source | Description |
|---|---|---|---|---|---|
| 1 | SSH | TCP | 22 | MY_IP/32 | SSH from my PC only |

**Outbound Rules:**
| Rule # | Type | Protocol | Port | Destination |
|---|---|---|---|---|
| 1 | All traffic | All | All | 0.0.0.0/0 |

**Why My IP /32 and not 0.0.0.0/0?**
```
0.0.0.0/0 → any IP in the world can attempt SSH
            = millions of automated bots try constantly
            = security risk even with key pair auth

MY_IP/32  → only your single IP can even attempt
            = everything else silently dropped at SG level
            = vastly smaller attack surface
```

---

### 2. private-sg

| Field | Value |
|---|---|
| Name | private-sg |
| VPC | my-custom-vpc |
| Purpose | Controls access to private application instances |

**Inbound Rules:**
| Rule # | Type | Protocol | Port | Source | Description |
|---|---|---|---|---|---|
| 1 | SSH | TCP | 22 | bastion-sg (SG ID) | SSH from bastion only |

**Outbound Rules:**
| Rule # | Type | Protocol | Port | Destination |
|---|---|---|---|---|
| 1 | All traffic | All | All | 0.0.0.0/0 |

**Why reference bastion-sg instead of an IP?**
```
If we used 10.0.1.5/32 (bastion private IP):
  Bastion stopped and restarted → new private IP 10.0.1.7
  Rule now blocks SSH → must manually update
  Fragile and error-prone

If we use sg-xxxxxxxx (bastion SG ID):
  Any instance with bastion-sg attached can SSH in
  Bastion stopped and restarted → still has bastion-sg
  Rule still works → zero maintenance
  This is called security group chaining
```

---

## Security Groups vs Network ACLs — Complete Comparison

### Quick Decision Guide
```
Need to DENY a specific IP?          → Use NACL (SGs cannot deny)
Protecting a specific EC2 instance?  → Use Security Group
Protecting an entire subnet?         → Use NACL
Need return traffic auto-allowed?    → Use Security Group (stateful)
Need rules to apply in order?        → Use NACL (numbered rules)
Both together?                       → Recommended for prod
```

### Detailed Comparison

| Feature | Security Group | Network ACL |
|---|---|---|
| Applies to | Individual EC2 instances (via ENI) | Entire subnet |
| State | Stateful | Stateless |
| Default action | Deny all inbound, Allow all outbound | Allow all in both directions |
| Rule types | Allow rules only | Allow AND Deny rules |
| Rule evaluation | All rules evaluated, most permissive wins | Rules evaluated in number order, first match wins |
| Return traffic | Automatically allowed (stateful) | Must explicitly allow (stateless) |
| Targets instances | You choose which instances | Applied to all instances in subnet |
| Maximum rules | 60 in + 60 out per SG | 20 in + 20 out per NACL (default) |

---

## Stateful vs Stateless Deep Dive

### Security Group — Stateful Example

```
Scenario: User requests your website on port 80

Inbound rule:  Allow TCP 80 from 0.0.0.0/0 ✅

User request arrives on port 80
  → Security group checks: inbound port 80 allowed? YES ✅
  → Request reaches EC2

EC2 sends response on random ephemeral port (e.g. 49152)
  → Security group: is this an established connection? YES ✅
  → Response automatically allowed — no outbound rule needed ✅

Result: You only need ONE inbound rule for HTTP to work
```

### Network ACL — Stateless Example

```
Scenario: Same website request on port 80

Inbound rule:  Allow TCP 80 from 0.0.0.0/0 ✅
Outbound rule: ??? (nothing added yet)

User request arrives on port 80
  → NACL checks inbound: port 80 allowed? YES ✅
  → Request reaches EC2

EC2 sends response on random ephemeral port (e.g. 49152)
  → NACL checks outbound: port 49152 allowed? NO ❌
  → Response BLOCKED — user sees broken website

Fix: Add outbound rule allowing TCP ports 1024-65535 (ephemeral range)
Result: You need BOTH inbound AND outbound rules for HTTP to work
```

---

## Network ACL Rule Numbering

Rules are evaluated lowest number first. First match wins.

```
Rule 100: Allow TCP 80 from 0.0.0.0/0   ← evaluated first
Rule 200: Allow TCP 443 from 0.0.0.0/0
Rule 300: Deny TCP 22 from 0.0.0.0/0
Rule *  : Deny all (cannot be modified)  ← evaluated last

Traffic on port 80 hits rule 100 → ALLOWED → stops evaluating
Traffic on port 22 hits rule 300 → DENIED  → stops evaluating
Traffic on port 8080 hits rule * → DENIED
```

**Best practice:** Number rules in increments of 100 (100, 200, 300...)
so you can insert new rules between existing ones without renumbering.

---

## Common Security Group Patterns

### Pattern 1 — Web server (public)
```
Inbound:
  HTTP  (80)  from 0.0.0.0/0  → public website
  HTTPS (443) from 0.0.0.0/0  → secure website
  SSH   (22)  from MY_IP/32   → admin access only
```

### Pattern 2 — Application server (private, behind ALB)
```
Inbound:
  HTTP (80) from alb-sg only  → traffic from ALB only, no direct access
  SSH  (22) from bastion-sg   → admin via bastion only
```

### Pattern 3 — Database (private, no internet)
```
Inbound:
  MySQL (3306) from app-sg only  → only app servers can query DB
  # No SSH rule — use SSM Session Manager instead
Outbound:
  # Remove default allow all
  # Databases should never initiate outbound connections
```

### Pattern 4 — Bastion host (this project)
```
Inbound:
  SSH (22) from MY_IP/32  → hardened single entry point
Outbound:
  All traffic → 0.0.0.0/0  → allows SSH out to private instances
```

---

## Security Group Chaining — This Project

```
Internet
   │ SSH:22
   ▼
[bastion-sg] ← My IP /32 can SSH in
Bastion Host
   │ SSH:22
   ▼
[private-sg] ← bastion-sg can SSH in (SG reference, not IP)
Private Instance
```

The chain means:
1. Only MY_IP can reach bastion (SSH)
2. Only bastion (via its SG) can reach private instance (SSH)
3. Internet → private instance directly = IMPOSSIBLE ✅

---

## IAM Policy for Security Group Management

If you need to give someone permission to manage security groups
without full EC2 access, use this policy pattern:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateSecurityGroup",
        "ec2:DeleteSecurityGroup",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:AuthorizeSecurityGroupEgress",
        "ec2:RevokeSecurityGroupIngress",
        "ec2:RevokeSecurityGroupEgress",
        "ec2:DescribeSecurityGroups"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "ec2:Vpc": "arn:aws:ec2:us-east-1:ACCOUNT_ID:vpc/VPC_ID"
        }
      }
    }
  ]
}
```

The Condition restricts changes to only your specific VPC —
not any VPC in the account. Least privilege applied.

---

## Quick Reference — Ports to Know

| Port | Protocol | Service |
|---|---|---|
| 22 | TCP | SSH |
| 80 | TCP | HTTP |
| 443 | TCP | HTTPS |
| 3306 | TCP | MySQL / Aurora MySQL |
| 5432 | TCP | PostgreSQL |
| 6379 | TCP | Redis / ElastiCache |
| 27017 | TCP | MongoDB |
| 8080 | TCP | Alternative HTTP |
| 8443 | TCP | Alternative HTTPS |
| 2049 | TCP/UDP | NFS (EFS) |
| 1024-65535 | TCP | Ephemeral ports (return traffic) |

<br>


<div align="center" style="margin: 30px 0; padding: 15px; border: 1px solid #e1e4e8; border-radius: 8px; background-color: #f6f8fa;">
  <table style="width: 100%; text-align: center; border: none; background: transparent;">
    <tr style="border: none;">
      <td style="width: 33%; border: none;"><a href='../../project-04-s3-versioning/README.md' style='font-size: 16px; text-decoration: none;'>⏪ <b>Previous: S3 Versioning</b></a></td>
      <td style="width: 33%; border: none;"><a href="../README.md" style="font-size: 16px; text-decoration: none;">🏠 <b>Project Home</b></a></td>
      <td style="width: 33%; border: none;"><a href='../../project-06-rds-ec2/README.md' style='font-size: 16px; text-decoration: none;'><b>Next: Rds Ec2</b> ⏩</a></td>
    </tr>
  </table>
</div>

