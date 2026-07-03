# Get Instance ID
$INSTANCE_ID = aws ec2 describe-instances --filters "Name=tag:Name,Values=my-first-ec2" --query "Reservations[*].Instances[*].InstanceId" --output text

# Step 1 — Terminate the instance (permanent deletion)
if ($INSTANCE_ID) {
    aws ec2 terminate-instances --instance-ids $INSTANCE_ID
    Write-Host "Waiting for instance to terminate..."
    aws ec2 wait instance-terminated --instance-ids $INSTANCE_ID
    Write-Host "Instance terminated"
}

# Get Security Group ID
$SG_ID = aws ec2 describe-security-groups --group-names ec2-web-sg --query "SecurityGroups[0].GroupId" --output text

# Step 2 — Delete the security group (must wait for instance to terminate first)
if ($SG_ID) {
    aws ec2 delete-security-group --group-id $SG_ID
    Write-Host "Security group deleted"
}

# Step 3 — Delete the key pair from AWS
aws ec2 delete-key-pair --key-name aws-ec2-keypair
Write-Host "Key pair deleted from AWS"

# Step 4 — Detach and delete IAM instance profile
aws iam remove-role-from-instance-profile `
  --instance-profile-name ec2-ssm-profile `
  --role-name ec2-ssm-role -ErrorAction SilentlyContinue

aws iam detach-role-policy `
  --role-name ec2-ssm-role `
  --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore -ErrorAction SilentlyContinue

aws iam delete-instance-profile --instance-profile-name ec2-ssm-profile -ErrorAction SilentlyContinue
aws iam delete-role --role-name ec2-ssm-role -ErrorAction SilentlyContinue

Write-Host "IAM role and profile deleted"

# Verify instance is gone
if ($INSTANCE_ID) {
    aws ec2 describe-instances `
      --instance-ids $INSTANCE_ID `
      --query "Reservations[0].Instances[0].State.Name" `
      --output text
}
