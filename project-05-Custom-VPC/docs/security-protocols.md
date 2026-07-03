# Security Protocols

- **Security Group Chaining:** Instead of allowing SSH traffic from the entire `10.0.0.0/16` network, the private security group explicitly trusts the ID of the Bastion security group. This prevents lateral movement.
- **No Public IPs:** Resources in the private subnet are never assigned public IPv4 addresses, making them mathematically impossible to reach directly from the internet.
- **Network ACLs:** (Optional) While Security Groups are stateful firewalls at the instance level, Network ACLs can be added at the subnet boundary as a stateless layer of defense.