# Troubleshooting

| Issue | Cause | Fix |
|---|---|---|
| **Instances have no internet access** | Missing Routes | Check the route tables. The public route table MUST have a `0.0.0.0/0` route to the IGW. The private route table MUST have a `0.0.0.0/0` route to the NAT GW. |
| **Cannot SSH into Bastion** | Auto-Assign Public IP | Ensure you enabled "Auto-assign public IPv4 address" on the public subnets before launching the instance. |
| **Cannot delete VPC** | Active Resources | A VPC cannot be deleted until all resources inside it (EC2, NAT, EIP, Subnets, IGW) are deleted first. See the cleanup guide. |