# Troubleshooting CloudFormation

CloudFormation abstracts away many complexities, but when a stack fails, debugging requires reading stack events carefully. Below are common errors and their resolutions.

## 💥 Common Stack Failures

| Error Status / Message | Root Cause | Resolution |
|:---|:---|:---|
| **`ROLLBACK_COMPLETE` immediately on create** | A resource failed to provision during initial stack creation. | Run `aws cloudformation describe-stack-events` and look for the first `CREATE_FAILED` event. The "Reason" column will explain exactly why. |
| **Cannot update stack in `ROLLBACK_COMPLETE`** | If a stack fails its *very first* creation attempt, it is dead. It cannot be updated. | You must run `delete-stack` to remove the dead stack, fix your template, and run `create-stack` again. |
| **`CREATE_FAILED` on VPC (CIDR overlap)** | The `VpcCIDR` you specified overlaps with another VPC in your account. | Change the `VpcCIDR` parameter to a non-overlapping range (e.g., `10.5.0.0/16`). |
| **`InsufficientCapabilitiesException`** | Your template creates IAM Roles/Policies, but you didn't grant CloudFormation permission to do so. | Always append `--capabilities CAPABILITY_IAM` or `CAPABILITY_NAMED_IAM` to your `create-stack` and `create-change-set` commands. |
| **Change Set shows `Replacement: True` unexpectedly** | You modified a property of a resource that is immutable (e.g., changing the Availability Zone of an existing Subnet or the Engine of an RDS DB). | CloudFormation must destroy the old resource and create a new one. Review AWS Documentation for the resource to see which properties require replacement. |
| **`DELETE_FAILED` during stack cleanup** | CloudFormation cannot delete a resource because it is not empty or is in use (e.g., an S3 bucket with files in it, or a Security Group attached to a manual EC2 instance). | Manually empty the S3 bucket or detach the ENI/Security Group via the console, then run `delete-stack` again. |

## 🔍 Debugging Toolkit (cfn-lint)

### 1. The Stack Events Command
This is your most powerful tool. The first error in the list is the root cause; everything after it is a symptom of the rollback.

```powershell
aws cloudformation describe-stack-events `
  --stack-name my-app-stack `
  --query "StackEvents[?ResourceStatus=='CREATE_FAILED' || ResourceStatus=='UPDATE_FAILED'].{Resource:LogicalResourceId,Reason:ResourceStatusReason}" `
  --output table
```

### 2. Validating Templates (cfn-lint)
While `aws cloudformation validate-template` checks basic JSON/YAML structure, it doesn't check AWS logic (e.g., if you used a valid instance type). 

To catch logical errors before deploying, install the AWS CloudFormation Linter:
```bash
pip install cfn-lint
cfn-lint templates/main-stack.yaml
```

### 3. Stack Stuck in `UPDATE_IN_PROGRESS`
Some resources inherently take a long time to provision or update. 
- RDS Databases: 10–20 minutes
- CloudFront Distributions: 15–30 minutes
- Auto Scaling Groups: Takes time to boot instances and pass ELB health checks.

**Do not panic** unless the stack has been stuck for over an hour. Do not attempt to cancel the stack manually; let the CloudFormation timeout handles it.

