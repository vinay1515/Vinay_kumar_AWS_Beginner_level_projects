# 03-execute-changeset.ps1

# Apply the change
aws cloudformation execute-change-set `
  --stack-name my-app-stack `
  --change-set-name increase-max-capacity

# Wait for update to complete
aws cloudformation wait stack-update-complete `
  --stack-name my-app-stack

Write-Host "Stack updated successfully"

# Verify the change applied
aws autoscaling describe-auto-scaling-groups `
  --auto-scaling-group-names cfn-web-app-asg `
  --query "AutoScalingGroups[0].MaxSize" --output text
