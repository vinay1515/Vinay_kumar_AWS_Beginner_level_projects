# Architecture Details

## Network Isolation
- **VPC CIDR:** `10.0.0.0/16` (65,536 IPs).
- **Public Subnets:** `10.0.1.0/24`, `10.0.2.0/24`. These subnets are attached to a Route Table that has a `0.0.0.0/0` route pointing to the Internet Gateway (IGW).
- **Private Subnets:** `10.0.3.0/24`, `10.0.4.0/24`. These subnets are attached to a Route Table that has a `0.0.0.0/0` route pointing to the NAT Gateway.

## Gateways
- **Internet Gateway (IGW):** Allows bidirectional traffic from the public internet.
- **NAT Gateway:** Deployed in a Public Subnet with an Elastic IP. Translates private IPs to a public IP to allow outbound-only internet access (for downloading patches/updates) while blocking inbound connections.