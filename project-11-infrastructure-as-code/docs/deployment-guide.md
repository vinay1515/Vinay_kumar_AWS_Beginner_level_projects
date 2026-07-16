# Deployment Guide

This guide covers the full lifecycle of a CloudFormation stack: Validation, Deployment, Modification, and Cleanup.

## 🛫 PRE-FLIGHT CHECKS

Ensure your CLI is authenticated and your region is correct.

```powershell
# Confirm region (should be ap-south-1)
aws configure get region

# Confirm identity
aws sts get-caller-identity

# Confirm your EC2 key pair exists in the region
aws ec2 describe-key-pairs --key-names aws-ec2-keypair `
  --query "KeyPairs[0].KeyName" --output text
```

## 1️⃣ PHASE 1: Validation

Always validate your template syntax locally before pushing it to AWS. This catches YAML formatting and structural errors immediately.

```powershell
aws cloudformation validate-template `
  --template-body file://templates/main-stack.yaml
```
*(If valid, it returns a JSON object detailing the Parameters and Description. If invalid, it returns the exact line number of the error.)*

## 2️⃣ PHASE 2: Initial Deployment (Create Stack)

Deploy the full VPC, ALB, and ASG stack using the CLI. We pass parameters dynamically here.

```powershell
aws cloudformation create-stack `
  --stack-name my-app-stack `
  --template-body file://templates/main-stack.yaml `
  --parameters `
    ParameterKey=ProjectName,ParameterValue=cfn-web-app `
    ParameterKey=EnvironmentType,ParameterValue=dev `
    ParameterKey=InstanceType,ParameterValue=t2.micro `
    ParameterKey=KeyPairName,ParameterValue=aws-ec2-keypair `
    ParameterKey=MinInstances,ParameterValue=2 `
    ParameterKey=MaxInstances,ParameterValue=4 `
    ParameterKey=DesiredInstances,ParameterValue=2 `
  --capabilities CAPABILITY_IAM

# Monitor the creation process until CREATE_COMPLETE
aws cloudformation wait stack-create-complete --stack-name my-app-stack
```

## 3️⃣ PHASE 3: Testing the Deployment

Once deployed, extract the ALB DNS URL from the CloudFormation **Outputs** section.

```powershell
$ALB_URL = aws cloudformation describe-stacks `
  --stack-name my-app-stack `
  --query "Stacks[0].Outputs[?OutputKey=='ALBUrl'].OutputValue" `
  --output text

Write-Host "Application URL: $ALB_URL"

# Wait ~2 minutes for instances to pass ALB health checks, then test:
Invoke-WebRequest -Uri $ALB_URL -UseBasicParsing | Select-Object StatusCode
```

## 4️⃣ PHASE 4: Safe Updates (Change Sets)

Never use `update-stack` directly in production. Always create a **Change Set** to preview the exact impact of your changes (e.g., ensuring a database isn't accidentally deleted).

1. Modify the `main-stack.yaml` template (e.g., change `MaxInstances` from 4 to 6).
2. **Create the Change Set:**

```powershell
aws cloudformation create-change-set `
  --stack-name my-app-stack `
  --change-set-name increase-capacity-preview `
  --template-body file://templates/main-stack.yaml `
  --parameters ... [same parameters as before] ...

aws cloudformation wait change-set-create-complete `
  --stack-name my-app-stack --change-set-name increase-capacity-preview
```

3. **Review the Change Set:**
Ensure `Replacement: False` for critical resources. If `True`, the resource will be destroyed and recreated, causing potential data loss or downtime.

```powershell
aws cloudformation describe-change-set `
  --stack-name my-app-stack `
  --change-set-name increase-capacity-preview `
  --query "Changes[*].ResourceChange.{Action:Action,Resource:LogicalResourceId,Replacement:Replacement}" `
  --output table
```

4. **Execute the Change Set:**

```powershell
aws cloudformation execute-change-set `
  --stack-name my-app-stack `
  --change-set-name increase-capacity-preview

aws cloudformation wait stack-update-complete --stack-name my-app-stack
```

## 5️⃣ PHASE 5: Cleanup (Teardown)

The greatest benefit of IaC: wiping out the entire environment cleanly. See the [Cleanup Guide](cleanup-guide.md) for full details.

```powershell
aws cloudformation delete-stack --stack-name my-app-stack
aws cloudformation wait stack-delete-complete --stack-name my-app-stack
```

