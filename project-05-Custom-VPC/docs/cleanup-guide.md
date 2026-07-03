# Cleanup Guide

> [!WARNING]
> You **MUST** delete the NAT Gateway as it incurs an hourly charge (~$0.045/hour), even if it is not being used.

To teardown the VPC, you must do it in the correct dependency order:
1. Terminate all EC2 instances.
2. Delete the NAT Gateway (this takes ~3-5 minutes to change to a 'Deleted' state).
3. Release the Elastic IP associated with the NAT Gateway.
4. Delete the Route Tables.
5. Detach the Internet Gateway from the VPC, then Delete the IGW.
6. Delete the Subnets.
7. Delete the VPC.