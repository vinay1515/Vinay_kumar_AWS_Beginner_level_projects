#!/bin/bash

# =============================================================================
# Project 9 — Script 01: Create IAM Roles
# Creates service roles for CodeBuild, CodeDeploy, CodePipeline, and EC2
# Region: ap-south-1
# =============================================================================

echo -e "\e[36m=== Project 9 — Create IAM Roles ===\e[0m"
echo ""

ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
echo "Account ID: $ACCOUNT_ID"
echo ""

# ── HELPER: CREATE ROLE ───────────────────────────────────────────────────────
function New-ServiceRole {
    param([string]$RoleName, [string]$ServicePrincipal)
echo -e "\e[33m  Creating role: $RoleName (principal: $ServicePrincipal)...\e[0m"
    aws iam create-role \
        --role-name $RoleName \
        --assume-role-policy-document "{
        \"Version\":\"2012-10-17\",
        \"Statement\":[{
          \"Effect\":\"Allow\",
          \"Principal\":{\"Service\":\"$ServicePrincipal\"},
          \"Action\":\"sts:AssumeRole\"
        }]
      }" | Out-Null
echo -e "\e[32m  Role created.\e[0m"
}

# ── 1: CODEBUILD SERVICE ROLE ─────────────────────────────────────────────────
echo -e "\e[33m[1/4] CodeBuild service role...\e[0m"
New-ServiceRole -RoleName "codebuild-service-role" -ServicePrincipal "codebuild.amazonaws.com"

aws iam attach-role-policy --role-name codebuild-service-role \
    --policy-arn arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess
aws iam attach-role-policy --role-name codebuild-service-role \
    --policy-arn arn:aws:iam::aws:policy/CloudWatchLogsFullAccess
aws iam attach-role-policy --role-name codebuild-service-role \
    --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess
aws iam attach-role-policy --role-name codebuild-service-role \
    --policy-arn arn:aws:iam::aws:policy/AWSCodeCommitReadOnly
echo -e "\e[32m  Policies attached.\e[0m"

# ── 2: CODEDEPLOY SERVICE ROLE ────────────────────────────────────────────────
echo -e "\e[33m[2/4] CodeDeploy service role...\e[0m"
New-ServiceRole -RoleName "codedeploy-service-role" -ServicePrincipal "codedeploy.amazonaws.com"

aws iam attach-role-policy --role-name codedeploy-service-role \
    --policy-arn arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole
echo -e "\e[32m  Policies attached.\e[0m"

# ── 3: CODEPIPELINE SERVICE ROLE ──────────────────────────────────────────────
echo -e "\e[33m[3/4] CodePipeline service role...\e[0m"
New-ServiceRole -RoleName "codepipeline-service-role" -ServicePrincipal "codepipeline.amazonaws.com"

aws iam attach-role-policy --role-name codepipeline-service-role \
    --policy-arn arn:aws:iam::aws:policy/AWSCodePipeline_FullAccess
aws iam attach-role-policy --role-name codepipeline-service-role \
    --policy-arn arn:aws:iam::aws:policy/AWSCodeCommitFullAccess
aws iam attach-role-policy --role-name codepipeline-service-role \
    --policy-arn arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess
aws iam attach-role-policy --role-name codepipeline-service-role \
    --policy-arn arn:aws:iam::aws:policy/AWSCodeDeployFullAccess
aws iam attach-role-policy --role-name codepipeline-service-role \
    --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess
echo -e "\e[32m  Policies attached.\e[0m"

# ── 4: EC2 CODEDEPLOY ROLE ────────────────────────────────────────────────────
echo -e "\e[33m[4/4] EC2 CodeDeploy instance role...\e[0m"
New-ServiceRole -RoleName "ec2-codedeploy-role" -ServicePrincipal "ec2.amazonaws.com"

aws iam attach-role-policy --role-name ec2-codedeploy-role \
    --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
aws iam attach-role-policy --role-name ec2-codedeploy-role \
    --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess

aws iam create-instance-profile \
    --instance-profile-name ec2-codedeploy-profile | Out-Null
aws iam add-role-to-instance-profile \
    --instance-profile-name ec2-codedeploy-profile \
    --role-name ec2-codedeploy-role
echo -e "\e[32m  Instance profile created and role attached.\e[0m"

# ── FETCH ARNS ────────────────────────────────────────────────────────────────
echo ""
echo -e "\e[33mFetching role ARNs...\e[0m"

CODEBUILD_ROLE_ARN=$(aws iam get-role --role-name codebuild-service-role  --query "Role.Arn" --output text)
CODEDEPLOY_ROLE_ARN=$(aws iam get-role --role-name codedeploy-service-role --query "Role.Arn" --output text)
PIPELINE_ROLE_ARN=$(aws iam get-role --role-name codepipeline-service-role --query "Role.Arn" --output text)

echo ""
echo -e "\e[36m=== IAM Roles Complete ===\e[0m"
echo "  CODEBUILD_ROLE_ARN:  $CODEBUILD_ROLE_ARN"
echo "  CODEDEPLOY_ROLE_ARN: $CODEDEPLOY_ROLE_ARN"
echo "  PIPELINE_ROLE_ARN:   $PIPELINE_ROLE_ARN"
echo ""
echo -e "\e[33mWaiting 15 seconds for IAM propagation...\e[0m"
sleep 15
echo -e "\e[36mNext step: Run 02-create-s3-bucket.ps1\e[0m"