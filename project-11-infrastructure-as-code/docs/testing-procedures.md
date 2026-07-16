# Testing & Operational Procedures

This document outlines how to test CloudFormation's operational safety features: Drift Detection and Automatic Rollbacks.

## 🧪 Scenario 1: Testing Drift Detection

Configuration drift occurs when a user modifies a resource via the AWS Console or CLI directly, bypassing CloudFormation. We will intentionally create drift and detect it.

### 1. Introduce Drift
1. Navigate to the **EC2 Console** -> **Security Groups**.
2. Find the Security Group named `cfn-web-app-alb-sg`.
3. Manually add a new Inbound Rule: Allow SSH (Port 22) from `0.0.0.0/0`.
4. Save the rule.

### 2. Detect the Drift via CLI
```powershell
# Start drift detection
$DRIFT_ID = aws cloudformation detect-stack-drift `
  --stack-name my-app-stack `
  --query "StackDriftDetectionId" --output text

Write-Host "Drift detection started: $DRIFT_ID"

# Wait a moment, then check which specific resources have drifted
aws cloudformation describe-stack-resource-drifts `
  --stack-name my-app-stack `
  --query "StackResourceDrifts[*].{
    Resource:LogicalResourceId,
    Expected:ExpectedProperties,
    Actual:ActualProperties,
    DriftStatus:StackResourceDriftStatus}" `
  --output table
```
**Expected Result:** The CLI will report the `ALBSecurityGroup` as `MODIFIED`, highlighting the disparity between the IaC template and the physical AWS state.

### 3. Remediate the Drift
To fix drift, you have two choices:
- Revert the manual change in the Console to match the template.
- Update the CloudFormation template to include the new rule and deploy an update (bringing the code in line with reality).

---

## 🚨 Scenario 2: Testing Automatic Rollbacks

CloudFormation guarantees atomic deployments: either the entire stack deploys successfully, or it fails and rolls back to its exact previous state.

### 1. Intentionally Break the Template
Modify `main-stack.yaml` and introduce a logical error that passes initial validation but fails at runtime. For example, change the `InstanceType` to a value that doesn't exist, or set `MinSize: 100` on the ASG to exceed your account quota.

### 2. Attempt the Update
Apply the update via a Change Set or `update-stack`.

### 3. Monitor the Rollback
Monitor the stack events:
```powershell
aws cloudformation describe-stack-events `
  --stack-name my-app-stack `
  --query "StackEvents[*].{Time:Timestamp,Resource:LogicalResourceId,Status:ResourceStatus,Reason:ResourceStatusReason}" `
  --output table
```
**Expected Result:**
1. You will see an `UPDATE_FAILED` status on the specific resource (with the reason provided).
2. CloudFormation will immediately trigger an `UPDATE_ROLLBACK_IN_PROGRESS`.
3. It will restore the previous configurations for all resources.
4. The final status will be `UPDATE_ROLLBACK_COMPLETE`.

Your application experiences zero downtime and your infrastructure remains in a safe, known state despite the failed deployment attempt.

