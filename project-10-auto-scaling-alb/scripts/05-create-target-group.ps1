# =============================================================================
# Project 10 — Script 05: Create Target Group
# Creates ALB target group with HTTP health checks on port 80
# Region: ap-south-1
# =============================================================================

Write-Host "=== Project 10 — Create Target Group ===" -ForegroundColor Cyan
Write-Host ""

# ── PRE-REQUISITES ────────────────────────────────────────────────────────────
$VPC_ID = aws ec2 describe-vpcs `
    --filters "Name=isDefault,Values=true" `
    --query "Vpcs[0].VpcId" --output text

Write-Host "  VPC: $VPC_ID" -ForegroundColor Green
Write-Host ""

# ── CREATE TARGET GROUP ───────────────────────────────────────────────────────
Write-Host "[1/1] Creating Target Group with health checks..." -ForegroundColor Yellow

$TG_ARN = aws elbv2 create-target-group `
    --name web-server-tg `
    --protocol HTTP `
    --port 80 `
    --vpc-id $VPC_ID `
    --health-check-protocol HTTP `
    --health-check-path "/" `
    --health-check-interval-seconds 30 `
    --health-check-timeout-seconds 5 `
    --healthy-threshold-count 2 `
    --unhealthy-threshold-count 2 `
    --matcher HttpCode=200 `
    --target-type instance `
    --query "TargetGroups[0].TargetGroupArn" `
    --output text

Write-Host "  Target Group ARN: $TG_ARN" -ForegroundColor Green

# ── VERIFY ────────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "Verifying target group..." -ForegroundColor Yellow
aws elbv2 describe-target-groups `
    --target-group-arns $TG_ARN `
    --query "TargetGroups[0].{Name:TargetGroupName,Protocol:Protocol,Port:Port,HealthPath:HealthCheckPath,HealthInterval:HealthCheckIntervalSeconds}" `
    --output table

# ── SUMMARY ───────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "=== Target Group Complete ===" -ForegroundColor Cyan
Write-Host "  Name:           web-server-tg"
Write-Host "  Protocol:       HTTP"
Write-Host "  Port:           80"
Write-Host "  Health Check:   HTTP GET / (every 30s, timeout 5s)"
Write-Host "  Healthy After:  2 consecutive checks"
Write-Host "  Unhealthy After: 2 consecutive failures"
Write-Host "  Success Code:   200"
Write-Host ""
Write-Host "  No targets registered yet — ASG will add instances automatically." -ForegroundColor Yellow
Write-Host ""
Write-Host "Next step: Run 06-create-alb.ps1" -ForegroundColor Cyan
