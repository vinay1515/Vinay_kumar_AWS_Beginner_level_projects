# 01-create-stack.ps1
# Create the stack
aws cloudformation create-stack `
  --stack-name my-app-stack `
  --template-body file://templates/main-stack.yaml `
  --parameters `
  ParameterKey=ProjectName, ParameterValue=cfn-web-app `
  ParameterKey=EnvironmentType, ParameterValue=dev `
  ParameterKey=InstanceType, ParameterValue=t2.micro `
  ParameterKey=KeyPairName, ParameterValue=aws-ec2-keypair `
  ParameterKey=MinInstances, ParameterValue=2 `
  ParameterKey=MaxInstances, ParameterValue=4 `
  ParameterKey=DesiredInstances, ParameterValue=2 `
  --capabilities CAPABILITY_IAM

Write-Host "Stack creation started..."

# Watch stack creation progress
aws cloudformation wait stack-create-complete `
  --stack-name my-app-stack

Write-Host "Stack CREATE_COMPLETE"

# Get the ALB URL
$ALB_URL = aws cloudformation describe-stacks `
  --stack-name my-app-stack `
  --query "Stacks[0].Outputs[?OutputKey=='ALBUrl'].OutputValue" `
  --output text

Write-Host "Application URL: $ALB_URL"
