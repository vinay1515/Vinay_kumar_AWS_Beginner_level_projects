# 🧹 Cleanup Guide

This guide covers the systematic tear-down of the RDS MySQL + EC2 Two-Tier Web Application infrastructure provisioned in this project.

> [!CAUTION]
> **This action is irreversible.** All resources listed below will be permanently deleted, including the RDS database and all its data. Ensure you have exported any data you need before proceeding.

## 📋 Resources to Delete

| # | Resource | Service | Deletion Order Reason |
|:---:|:---|:---|:---|
| 1 | EC2 Instance | EC2 | Must terminate before removing security groups |
| 2 | RDS Database Instance | RDS | Must delete before removing subnet group and security groups |
| 3 | DB Subnet Group | RDS | Cannot delete while RDS instance exists |
| 4 | Secrets Manager Secret | Secrets Manager | Remove credential storage |
| 5 | IAM Role + Instance Profile | IAM | Remove EC2 role for Secrets Manager access |
| 6 | Security Groups (EC2 + RDS) | VPC | Cannot delete while attached to instances/RDS |
| 7 | CloudWatch Log Groups | CloudWatch | Clean up any application logs |

> [!WARNING]
> **Deletion order matters.** RDS instances have dependencies on subnet groups and security groups. You must delete resources in the order listed above to avoid `DependencyViolation` errors.

## 🖥️ Method 1: AWS Management Console

1. Go to **EC2** → **Instances** → Select the app server instance → **Instance state** → **Terminate instance**.
2. Go to **RDS** → **Databases** → Select `my-rds-mysql`:
   - Click **Modify** → Disable **Deletion Protection** → **Continue** → **Apply Immediately**.
   - Click **Actions** → **Delete** → Uncheck "Create final snapshot" → Type `delete me` → **Delete**.
   - Wait 5–10 minutes for the RDS instance to finish deleting.
3. Go to **RDS** → **Subnet Groups** → Select the subnet group → **Delete**.
4. Go to **Secrets Manager** → Select `rds-credentials` → **Actions** → **Delete secret** → Schedule deletion (minimum 7 days) or force delete.
5. Go to **IAM** → **Roles** → Search for the EC2 Secrets Manager role → Detach all policies → **Delete role**.
6. Go to **VPC** → **Security Groups** → Delete the RDS security group first, then the EC2 security group.
7. Go to **CloudWatch** → **Log Groups** → Delete any log groups created by this project.

## 🐧 Method 2: AWS CLI (Bash)
```bash
#!/bin/bash
# =============================================================================
# Project 06 — Cleanup: Tears down the entire RDS + EC2 architecture
# Region: ap-south-1
# =============================================================================

# Load environment variables
if [ -f "../../.env" ]; then
    source ../../.env
elif [ -f "../.env" ]; then
    source ../.env
elif [ -f ".env" ]; then
    source .env
else
    echo -e "\e[31mError: .env file not found.\e[0m"
    exit 1
fi

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION="${AWS_REGION:-ap-south-1}"

echo -e "\e[36m=== Project 06 — Full Cleanup ===\e[0m"
echo ""
echo -e "\e[31m  This will delete ALL resources created in Project 06.\e[0m"
echo ""

# ── STEP 1: TERMINATE EC2 INSTANCE ────────────────────────────────────────────
echo -e "\e[33m[1/7] Terminating EC2 instance...\e[0m"
INSTANCE_ID=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=*rds*app*" "Name=instance-state-name,Values=running,stopped" \
    --query "Reservations[0].Instances[0].InstanceId" --output text 2>/dev/null)

if [ -n "$INSTANCE_ID" ] && [ "$INSTANCE_ID" != "None" ]; then
    aws ec2 terminate-instances --instance-ids "$INSTANCE_ID"
    echo -e "\e[32m  Terminated: $INSTANCE_ID\e[0m"
    echo -e "\e[90m  Waiting for instance to terminate...\e[0m"
    aws ec2 wait instance-terminated --instance-ids "$INSTANCE_ID"
    echo -e "\e[32m  Instance terminated.\e[0m"
else
    echo -e "\e[90m  No matching EC2 instance found.\e[0m"
fi

# ── STEP 2: DELETE RDS INSTANCE ───────────────────────────────────────────────
echo ""
echo -e "\e[33m[2/7] Deleting RDS instance...\e[0m"
DB_ID="${DB_INSTANCE_ID:-my-rds-mysql}"

if aws rds describe-db-instances --db-instance-identifier "$DB_ID" &>/dev/null; then
    # Disable deletion protection first
    aws rds modify-db-instance \
        --db-instance-identifier "$DB_ID" \
        --no-deletion-protection \
        --apply-immediately 2>/dev/null
    sleep 10

    aws rds delete-db-instance \
        --db-instance-identifier "$DB_ID" \
        --skip-final-snapshot \
        --delete-automated-backups
    echo -e "\e[32m  RDS deletion initiated: $DB_ID\e[0m"
    echo -e "\e[90m  Waiting for RDS to delete (this takes 5-10 minutes)...\e[0m"
    aws rds wait db-instance-deleted --db-instance-identifier "$DB_ID"
    echo -e "\e[32m  RDS instance deleted.\e[0m"
else
    echo -e "\e[90m  RDS instance not found or already deleted.\e[0m"
fi

# ── STEP 3: DELETE DB SUBNET GROUP ────────────────────────────────────────────
echo ""
echo -e "\e[33m[3/7] Deleting DB Subnet Group...\e[0m"
if aws rds delete-db-subnet-group --db-subnet-group-name my-db-subnet-group 2>/dev/null; then
    echo -e "\e[32m  DB Subnet Group deleted.\e[0m"
else
    echo -e "\e[90m  DB Subnet Group not found or already deleted.\e[0m"
fi

# ── STEP 4: DELETE SECRET ─────────────────────────────────────────────────────
echo ""
echo -e "\e[33m[4/7] Deleting Secrets Manager secret...\e[0m"
if aws secretsmanager delete-secret \
    --secret-id rds-credentials \
    --force-delete-without-recovery 2>/dev/null; then
    echo -e "\e[32m  Secret deleted (force, no recovery).\e[0m"
else
    echo -e "\e[90m  Secret not found or already deleted.\e[0m"
fi

# ── STEP 5: DELETE IAM ROLE ───────────────────────────────────────────────────
echo ""
echo -e "\e[33m[5/7] Deleting IAM Role and Instance Profile...\e[0m"
ROLE_NAME="ec2-secrets-manager-role"

# Remove role from instance profile
aws iam remove-role-from-instance-profile \
    --instance-profile-name "$ROLE_NAME" \
    --role-name "$ROLE_NAME" 2>/dev/null

# Delete instance profile
aws iam delete-instance-profile --instance-profile-name "$ROLE_NAME" 2>/dev/null

# Detach all policies from role
POLICIES=$(aws iam list-attached-role-policies --role-name "$ROLE_NAME" \
    --query "AttachedPolicies[].PolicyArn" --output text 2>/dev/null)
for POLICY_ARN in $POLICIES; do
    aws iam detach-role-policy --role-name "$ROLE_NAME" --policy-arn "$POLICY_ARN"
done

# Delete inline policies
INLINE_POLICIES=$(aws iam list-role-policies --role-name "$ROLE_NAME" \
    --query "PolicyNames[]" --output text 2>/dev/null)
for POLICY_NAME in $INLINE_POLICIES; do
    aws iam delete-role-policy --role-name "$ROLE_NAME" --policy-name "$POLICY_NAME"
done

# Delete role
if aws iam delete-role --role-name "$ROLE_NAME" 2>/dev/null; then
    echo -e "\e[32m  IAM role deleted: $ROLE_NAME\e[0m"
else
    echo -e "\e[90m  IAM role not found or already deleted.\e[0m"
fi

# ── STEP 6: DELETE SECURITY GROUPS ────────────────────────────────────────────
echo ""
echo -e "\e[33m[6/7] Deleting Security Groups...\e[0m"
for SG_NAME in "rds-mysql-sg" "ec2-app-sg"; do
    SG_ID=$(aws ec2 describe-security-groups \
        --filters "Name=group-name,Values=$SG_NAME" \
        --query "SecurityGroups[0].GroupId" --output text 2>/dev/null)
    if [ -n "$SG_ID" ] && [ "$SG_ID" != "None" ]; then
        aws ec2 delete-security-group --group-id "$SG_ID"
        echo -e "\e[32m  Deleted: $SG_NAME ($SG_ID)\e[0m"
    else
        echo -e "\e[90m  $SG_NAME not found.\e[0m"
    fi
done

# ── STEP 7: DELETE CLOUDWATCH LOG GROUPS ──────────────────────────────────────
echo ""
echo -e "\e[33m[7/7] Deleting CloudWatch Log Groups...\e[0m"
aws logs delete-log-group --log-group-name "/aws/rds/instance/$DB_ID/error" 2>/dev/null
echo -e "\e[32m  Log groups cleanup attempted.\e[0m"

echo ""
echo -e "\e[32m================================================\e[0m"
echo -e "\e[32m  Project 06 Cleanup Complete!\e[0m"
echo -e "\e[32m================================================\e[0m"
```

## 🪟 Method 3: AWS CLI (PowerShell)
```powershell
<#
.SYNOPSIS
Project 06 — Cleanup: Tears down the entire RDS + EC2 architecture.
Region: ap-south-1
#>

# Load environment variables
$envFile = Join-Path (Split-Path $MyInvocation.MyCommand.Path -Parent) "..\..\..\.env"
if (-not (Test-Path $envFile)) {
    $envFile = Join-Path (Split-Path $MyInvocation.MyCommand.Path -Parent) "..\..\.env"
}
if (-not (Test-Path $envFile)) {
    $envFile = Join-Path (Split-Path $MyInvocation.MyCommand.Path -Parent) "..\.env"
}
if (-not (Test-Path $envFile)) {
    $envFile = ".env"
}

if (Test-Path $envFile) {
    Get-Content $envFile | Where-Object { $_ -match '^export\s+([^=]+)=(.*)$' } | ForEach-Object {
        $name = $matches[1].Trim()
        $value = $matches[2].Trim(' "''')
        Set-Item -Path "env:\$name" -Value $value
    }
} else {
    Write-Host "Error: .env file not found." -ForegroundColor Red
    exit 1
}

$Region = $env:AWS_REGION ?? "ap-south-1"
$DbId = $env:DB_INSTANCE_ID ?? "my-rds-mysql"

Write-Host "=== Project 06 — Full Cleanup ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "  This will delete ALL resources created in Project 06." -ForegroundColor Red
Write-Host ""

# ── STEP 1: TERMINATE EC2 INSTANCE ────────────────────────────────────────────
Write-Host "[1/7] Terminating EC2 instance..." -ForegroundColor Yellow
$InstanceId = aws ec2 describe-instances `
    --filters "Name=tag:Name,Values=*rds*app*" "Name=instance-state-name,Values=running,stopped" `
    --query "Reservations[0].Instances[0].InstanceId" --output text 2>$null

if ($InstanceId -and $InstanceId -ne "None") {
    aws ec2 terminate-instances --instance-ids $InstanceId
    Write-Host "  Terminated: $InstanceId" -ForegroundColor Green
    Write-Host "  Waiting for instance to terminate..." -ForegroundColor DarkGray
    aws ec2 wait instance-terminated --instance-ids $InstanceId
    Write-Host "  Instance terminated." -ForegroundColor Green
} else {
    Write-Host "  No matching EC2 instance found." -ForegroundColor DarkGray
}

# ── STEP 2: DELETE RDS INSTANCE ───────────────────────────────────────────────
Write-Host ""
Write-Host "[2/7] Deleting RDS instance..." -ForegroundColor Yellow
try {
    aws rds modify-db-instance --db-instance-identifier $DbId `
        --no-deletion-protection --apply-immediately 2>$null
    Start-Sleep -Seconds 10

    aws rds delete-db-instance --db-instance-identifier $DbId `
        --skip-final-snapshot --delete-automated-backups
    Write-Host "  RDS deletion initiated: $DbId" -ForegroundColor Green
    Write-Host "  Waiting for RDS to delete (5-10 minutes)..." -ForegroundColor DarkGray
    aws rds wait db-instance-deleted --db-instance-identifier $DbId
    Write-Host "  RDS instance deleted." -ForegroundColor Green
} catch {
    Write-Host "  RDS instance not found or already deleted." -ForegroundColor DarkGray
}

# ── STEP 3: DELETE DB SUBNET GROUP ────────────────────────────────────────────
Write-Host ""
Write-Host "[3/7] Deleting DB Subnet Group..." -ForegroundColor Yellow
aws rds delete-db-subnet-group --db-subnet-group-name my-db-subnet-group 2>$null
Write-Host "  DB Subnet Group cleanup attempted." -ForegroundColor Green

# ── STEP 4: DELETE SECRET ─────────────────────────────────────────────────────
Write-Host ""
Write-Host "[4/7] Deleting Secrets Manager secret..." -ForegroundColor Yellow
aws secretsmanager delete-secret --secret-id rds-credentials `
    --force-delete-without-recovery 2>$null
Write-Host "  Secret cleanup attempted." -ForegroundColor Green

# ── STEP 5: DELETE IAM ROLE ───────────────────────────────────────────────────
Write-Host ""
Write-Host "[5/7] Deleting IAM Role and Instance Profile..." -ForegroundColor Yellow
$RoleName = "ec2-secrets-manager-role"

aws iam remove-role-from-instance-profile --instance-profile-name $RoleName `
    --role-name $RoleName 2>$null
aws iam delete-instance-profile --instance-profile-name $RoleName 2>$null

$Policies = aws iam list-attached-role-policies --role-name $RoleName `
    --query "AttachedPolicies[].PolicyArn" --output text 2>$null
if ($Policies) {
    foreach ($PolicyArn in ($Policies -split "\t")) {
        aws iam detach-role-policy --role-name $RoleName --policy-arn $PolicyArn
    }
}

aws iam delete-role --role-name $RoleName 2>$null
Write-Host "  IAM role cleanup attempted." -ForegroundColor Green

# ── STEP 6: DELETE SECURITY GROUPS ────────────────────────────────────────────
Write-Host ""
Write-Host "[6/7] Deleting Security Groups..." -ForegroundColor Yellow
foreach ($SgName in @("rds-mysql-sg", "ec2-app-sg")) {
    $SgId = aws ec2 describe-security-groups `
        --filters "Name=group-name,Values=$SgName" `
        --query "SecurityGroups[0].GroupId" --output text 2>$null
    if ($SgId -and $SgId -ne "None") {
        aws ec2 delete-security-group --group-id $SgId
        Write-Host "  Deleted: $SgName ($SgId)" -ForegroundColor Green
    } else {
        Write-Host "  $SgName not found." -ForegroundColor DarkGray
    }
}

# ── STEP 7: DELETE CLOUDWATCH LOG GROUPS ──────────────────────────────────────
Write-Host ""
Write-Host "[7/7] Deleting CloudWatch Log Groups..." -ForegroundColor Yellow
aws logs delete-log-group --log-group-name "/aws/rds/instance/$DbId/error" 2>$null
Write-Host "  Log groups cleanup attempted." -ForegroundColor Green

Write-Host ""
Write-Host "================================================" -ForegroundColor Green
Write-Host "  Project 06 Cleanup Complete!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
```

## ✅ Cleanup Verification

Run these commands to confirm all resources have been deleted:

```bash
# Verify EC2 instance is terminated
aws ec2 describe-instances --filters "Name=tag:Name,Values=*rds*app*" \
    --query "Reservations[].Instances[?State.Name!='terminated'].InstanceId" --output text

# Verify RDS instance is gone
aws rds describe-db-instances --db-instance-identifier my-rds-mysql 2>&1 | grep "DBInstanceNotFound"

# Verify DB Subnet Group is gone
aws rds describe-db-subnet-groups --db-subnet-group-name my-db-subnet-group 2>&1 | grep "DBSubnetGroupNotFoundFault"

# Verify secret is deleted
aws secretsmanager describe-secret --secret-id rds-credentials 2>&1 | grep -E "ResourceNotFoundException|DeletionDate"

# Verify security groups are gone
aws ec2 describe-security-groups --filters "Name=group-name,Values=rds-mysql-sg,ec2-app-sg" \
    --query "SecurityGroups[].GroupId" --output text
```

## 💰 Cost Implications

After cleanup, the following charges **stop immediately**:

| Resource | Charge That Stops |
|:---|:---|
| RDS db.t3.micro | ~$0.017/hr ($12.24/month if left running) |
| EC2 t2.micro | Free Tier (750 hrs/month) — but releases the slot |
| EBS Volumes | ~$0.08/GB/month (attached to EC2/RDS) |
| Secrets Manager | $0.40/secret/month |

> [!TIP]
> If you are within the AWS Free Tier period, the primary cost savings come from deleting the **Secrets Manager** secret ($0.40/month) and ensuring the RDS instance doesn't consume your 750 free hours.
