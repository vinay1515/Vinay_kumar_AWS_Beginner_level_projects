## 🛡️ Enterprise Security Group Specifications (Firewall Rules)

In AWS, a **Security Group** acts as a virtual firewall operating at the instance level (Network Layer 4). It strictly dictates what traffic can reach the Elastic Network Interface (ENI) attached to your EC2 instance.

**Security Group Name:** `ec2-web-sg`
**VPC:** Default VPC

| Direction | Port Range | Protocol | Source / Destination | Business Purpose |
|---|---|---|---|---|
| **Inbound** | 22 | TCP | `<Your-Public-IP>/32` | **Administration:** Restricts SSH access exclusively to your current physical location, mitigating global brute-force attacks. |
| **Inbound** | 80 | TCP | `0.0.0.0/0` | **Public Web Traffic:** Allows any anonymous user on the internet to view the Apache website over unencrypted HTTP. |
| **Outbound** | All | All | `0.0.0.0/0` | **Egress Traffic:** Allows the server to initiate connections outward (e.g., to download OS updates via `yum` or clone repos via `git`). |

### 🧠 Architectural Concept: Stateful Firewalls
Security groups are **stateful**. This means if you send a request from your EC2 instance out to the internet (e.g., running `curl https://google.com`), the response traffic from Google is *automatically* allowed back in, regardless of your inbound rules. 
*(Contrast this with Network ACLs, which operate at the subnet level and are stateless, requiring explicit return rules).*

---

## 🔐 Identity & Access Management: The EC2 Instance Profile

If your EC2 instance needs to interact with other AWS services (like reading from an S3 bucket or communicating with AWS Systems Manager), it requires AWS credentials.

### The Anti-Pattern: Hardcoded Access Keys
Never run `aws configure` inside an EC2 instance or hardcode an `Access Key ID` and `Secret Access Key` into a script. If a hacker breaches your web server (e.g., via a PHP vulnerability), they can easily steal those plaintext keys and compromise your entire AWS account.

### The Enterprise Standard: IAM Roles & Instance Profiles
Instead, we attach an **IAM Role** to the EC2 instance using a container called an **Instance Profile**.

```json
{
  "RoleName": "ec2-ssm-role",
  "TrustedEntity": {
    "Service": "ec2.amazonaws.com"
  },
  "AttachedPolicy": "AmazonSSMManagedInstanceCore"
}
```

**How it works under the hood:**
1. The Trust Policy allows the EC2 hypervisor (`ec2.amazonaws.com`) to assume the role on behalf of the virtual machine.
2. AWS automatically generates temporary, cryptographically signed credentials (valid for a few hours).
3. AWS injects these temporary credentials into the instance's localized metadata service (`http://169.254.169.254/latest/meta-data/`).
4. The AWS CLI or SDKs running on the server automatically fetch and use these credentials transparently. The keys rotate automatically, completely neutralizing the risk of long-term credential theft.

---