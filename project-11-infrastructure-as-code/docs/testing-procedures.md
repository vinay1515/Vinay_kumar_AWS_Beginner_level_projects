# Testing Procedures

## Test Rollback Behavior
1. Modify your `main-stack.yaml` to include a deliberate error (e.g., set an EC2 instance type to a non-existent size like `t2.superhuge`).
2. Attempt to update the stack.
3. Watch the "Events" tab in the CloudFormation console.
4. *Expected Result:* The stack will encounter an error provisioning the EC2 resource and will automatically trigger an `UPDATE_ROLLBACK_IN_PROGRESS`, safely reverting all previous successful changes in that update to return the environment to its last known good state.

## Verify Outputs
1. Once a successful deployment is complete, navigate to the Outputs tab.
2. Click the ALB URL. Ensure the web application loads correctly.