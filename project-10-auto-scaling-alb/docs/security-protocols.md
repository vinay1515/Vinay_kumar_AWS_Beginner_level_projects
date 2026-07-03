# Security Protocols

- **Security Group Chaining:** The ALB Security Group (`ALB-SG`) allows Port 80 inbound from `0.0.0.0/0`. The EC2 Security Group (`EC2-SG`) allows Port 80 inbound *only* from the ID of `ALB-SG`. This prevents users from bypassing the load balancer to hit the instances directly.
- **High Availability:** By spanning the ASG and ALB across multiple Availability Zones, the architecture remains fully operational even if an entire AWS datacenter goes offline.