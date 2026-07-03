# Cleanup Guide

To avoid ongoing EC2 charges, you must delete the resources. Because the ASG is designed to replace terminated instances, **you cannot just terminate the EC2 instances** (the ASG will just launch more). You must delete the ASG itself.

1. **Delete Auto Scaling Group:** Navigate to ASG, select your group, and click Delete. Wait for it to spin down the instances.
2. **Delete Application Load Balancer:** Navigate to Load Balancers and delete the ALB.
3. **Delete Target Group:** Navigate to Target Groups and delete the group.
4. **Delete Launch Template:** Navigate to Launch Templates and delete it.
