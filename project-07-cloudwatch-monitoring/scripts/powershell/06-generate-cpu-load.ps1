# =============================================================================
# Project 7 — Script 06: Generate CPU Load
# Run this locally to get SSH instructions for the EC2 instance
# =============================================================================

Write-Host "=== Project 7 — CPU Load Generator ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Purpose: Push CPU above 70% for 2 consecutive 5-minute periods"
Write-Host "This triggers the EC2-CPU-High CloudWatch alarm."
Write-Host ""
Write-Host "To generate CPU load, you must SSH into the EC2 instance and run stress." -ForegroundColor Yellow
Write-Host ""

if (-not $MON_INSTANCE_ID) {
    $MON_INSTANCE_ID = aws ec2 describe-instances `
      --filters "Name=tag:Name,Values=monitoring-test" `
      --query "Reservations[0].Instances[0].InstanceId" `
      --output text
}

if ($MON_INSTANCE_ID -and $MON_INSTANCE_ID -ne "None") {
    $MON_PUBLIC_IP = aws ec2 describe-instances `
      --instance-ids $MON_INSTANCE_ID `
      --query "Reservations[0].Instances[0].PublicIpAddress" `
      --output text

    Write-Host "1. Open a new terminal and run:" -ForegroundColor Green
    Write-Host "   ssh -i aws-ec2-keypair.pem ec2-user@$MON_PUBLIC_IP"
    Write-Host ""
    Write-Host "2. Once connected, run the following commands:" -ForegroundColor Green
    Write-Host "   sudo yum install -y stress"
    Write-Host "   sudo stress --cpu 1 --timeout 720"
    Write-Host ""
    Write-Host "3. Watch the alarm state change in the AWS Console (CloudWatch -> Alarms)." -ForegroundColor Green
} else {
    Write-Host "Could not find monitoring-test instance. Please launch it first." -ForegroundColor Red
}
