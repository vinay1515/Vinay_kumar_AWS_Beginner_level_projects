#!/bin/bash

# =============================================================================
# Project 10 — Script 07: Create Auto Scaling Group
# Creates ASG with min:2, max:4, desired:2, ELB health checks, CPU scaling
# Region: ap-south-1
# =============================================================================

echo -e "\e[36m=== Project 10 — Create Auto Scaling Group ===\e[0m"
echo ""

# ── PRE-REQUISITES ────────────────────────────────────────────────────────────
VPC_ID=$(aws ec2 describe-vpcs \
  --filters "Name=isDefault,Values=true" \
  --query "Vpcs[0].VpcId" --output text)

SUBNETS=$(aws ec2 describe-subnets \
  --filters "Name=vpc-id,Values=$VPC_ID" \
  "Name=defaultForAz,Values=true" \
  --query "Subnets[*].SubnetId" \
  --output text)

SUBNET_LIST=($SUBNETS)
SUBNET_A=${SUBNET_LIST[0]}
SUBNET_B=${SUBNET_LIST[1]}

LT_ID=$(aws ec2 describe-launch-templates \
  --launch-template-names web-server-lt \
  --query "LaunchTemplates[0].LaunchTemplateId" --output text)

TG_ARN=$(aws elbv2 describe-target-groups \
  --names web-server-tg \
  --query "TargetGroups[0].TargetGroupArn" --output text)

echo -e "\e[32m  VPC:              $VPC_ID\e[0m"
echo -e "\e[32m  Subnets:          $SUBNET_A, $SUBNET_B\e[0m"
echo -e "\e[32m  Launch Template:  $LT_ID\e[0m"
echo -e "\e[32m  Target Group:     $TG_ARN\e[0m"
echo ""

# ── CREATE AUTO SCALING GROUP ─────────────────────────────────────────────────
echo -e "\e[33m[1/2] Creating Auto Scaling Group...\e[0m"

aws autoscaling create-auto-scaling-group \
  --auto-scaling-group-name web-server-asg \
  --launch-template "LaunchTemplateId=$LT_ID,Version=\$Latest" \
  --min-size 2 \
  --max-size 4 \
  --desired-capacity 2 \
  --vpc-zone-identifier "$SUBNET_A,$SUBNET_B" \
  --target-group-arns $TG_ARN \
  --health-check-type ELB \
  --health-check-grace-period 120 \
  --tags "Key=Name,Value=asg-web-server,PropagateAtLaunch=true" \
  "Key=Project,Value=project-10-asg-alb,PropagateAtLaunch=true"

echo -e "\e[32m  ASG created: web-server-asg\e[0m"
echo -e "\e[32m  Min: 2 | Desired: 2 | Max: 4\e[0m"
echo -e "\e[32m  Health Check: ELB (ALB), Grace Period: 120s\e[0m"

# ── ADD TARGET TRACKING SCALING POLICY ────────────────────────────────────────
echo ""
echo -e "\e[33m[2/2] Adding CPU target tracking scaling policy...\e[0m"

aws autoscaling put-scaling-policy \
  --auto-scaling-group-name web-server-asg \
  --policy-name cpu-target-tracking \
  --policy-type TargetTrackingScaling \
  --target-tracking-configuration "{
      \"PredefinedMetricSpecification\":{
        \"PredefinedMetricType\":\"ASGAverageCPUUtilization\"
      },
      \"TargetValue\":50.0,
      \"EstimatedInstanceWarmup\":120
    }" | Out-Null

echo -e "\e[32m  Scaling policy: cpu-target-tracking\e[0m"
echo -e "\e[32m  Target: 50% average CPU utilization\e[0m"
echo -e "\e[32m  Warmup: 120 seconds\e[0m"

# ── WAIT FOR INSTANCES ────────────────────────────────────────────────────────
echo ""
echo -e "\e[33mWaiting for instances to launch (60 seconds)...\e[0m"
sleep 60

# ── CHECK STATUS ──────────────────────────────────────────────────────────────
echo ""
echo -e "\e[33mChecking ASG status...\e[0m"
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names web-server-asg \
  --query "AutoScalingGroups[0].{
      Name:AutoScalingGroupName,
      Min:MinSize,
      Max:MaxSize,
      Desired:DesiredCapacity,
      Instances:Instances[*].{ID:InstanceId,State:LifecycleState,Health:HealthStatus,AZ:AvailabilityZone}
    }" \
  --output json

# ── SUMMARY ───────────────────────────────────────────────────────────────────
echo ""
echo -e "\e[36m=== Auto Scaling Group Complete ===\e[0m"
echo "  ASG Name:        web-server-asg"
echo "  Min/Desired/Max: 2 / 2 / 4"
echo "  Scaling Policy:  CPU target tracking at 50%"
echo "  Health Check:    ELB (ALB checks via Target Group)"
echo "  Subnets:         2 AZs for high availability"
echo ""
echo -e "\e[33m  Instances are launching — it takes 2-3 minutes to pass health checks.\e[0m"
echo ""
echo -e "\e[36mNext step: Run 08-verify-and-test.sh\e[0m"
