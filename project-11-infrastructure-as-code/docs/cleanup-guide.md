# Cleanup Guide

Because everything is managed by CloudFormation, teardown requires only a single action.

1. Navigate to the CloudFormation Console.
2. Select `my-app-stack`.
3. Click **Delete**.

CloudFormation will automatically parse the dependency tree in reverse, terminating the ASG instances, deleting the ALB, removing the Security Groups, and deleting the VPC. Wait for the status to reach `DELETE_COMPLETE`.
