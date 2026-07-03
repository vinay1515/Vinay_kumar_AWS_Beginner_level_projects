# Cleanup Guide

To stop incurring charges for running EC2 compute time, perform the following cleanup:

1. **Terminate the Instance:** In the EC2 Console, select your instance, go to Instance State, and click **Terminate**. This permanently deletes the instance and its attached EBS volume. (Note: *Stopping* the instance pauses compute billing, but you still pay for the EBS volume storage).
2. **Delete the Security Group:** Once the instance is fully terminated, navigate to Security Groups and delete the custom group you created.
3. **Delete the IAM Role:** Navigate to IAM, detach the policy from `ec2-ssm-role`, and delete the role.