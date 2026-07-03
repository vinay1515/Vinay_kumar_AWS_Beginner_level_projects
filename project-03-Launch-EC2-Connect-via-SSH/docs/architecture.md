# Architecture Details

## Amazon EC2 Instance
- **Instance Type:** `t2.micro` (1 vCPU, 1 GiB RAM).
- **AMI:** Amazon Linux 2023.
- **User Data:** A bash script passed to the instance at launch that automatically updates packages, installs Apache (`httpd`), and creates a custom `index.html`.

## Security Group (Stateful Firewall)
- **Inbound Port 80 (HTTP):** Open to `0.0.0.0/0` to allow anyone to view the website.
- **Inbound Port 22 (SSH):** Restricted to your specific IP address for traditional SSH (PuTTY).
- **Outbound:** Open to `0.0.0.0/0` (Default).

## IAM Instance Profile (SSM)
An IAM Role containing the `AmazonSSMManagedInstanceCore` policy is attached to the instance, allowing the SSM Agent on the EC2 instance to communicate securely with the AWS Systems Manager API.