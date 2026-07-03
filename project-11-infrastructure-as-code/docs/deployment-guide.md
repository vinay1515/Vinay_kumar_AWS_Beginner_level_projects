# Deployment Guide

## Step 1: Validate Template
Before deploying, always validate the YAML syntax using the AWS CLI:
```bash
aws cloudformation validate-template --template-body file://main-stack.yaml
```

## Step 2: Create Stack
Execute the stack creation. CloudFormation will begin provisioning resources in the correct dependency order.
```bash
aws cloudformation create-stack \
  --stack-name my-app-stack \
  --template-body file://main-stack.yaml
```
Monitor the progress in the CloudFormation Console under the "Events" tab.

## Step 3: Update via Change Sets
If you modify the YAML template (e.g. changing MinSize to 3), do not delete the stack. Instead, create a Change Set:
```bash
aws cloudformation create-change-set \
  --stack-name my-app-stack \
  --change-set-name scale-up-update \
  --template-body file://main-stack-v2.yaml
```
Review the change set in the console, then execute it to update the live infrastructure.