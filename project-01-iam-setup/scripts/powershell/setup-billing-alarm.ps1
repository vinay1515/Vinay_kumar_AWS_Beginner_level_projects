<#
.SYNOPSIS
Creates an SNS topic for billing alerts and a CloudWatch alarm.

.DESCRIPTION
This script automates Checkpoint B of the IAM Setup project.
#>

param (
    [Parameter(Mandatory=$true)]
    [string]$EmailAddress,
    
    [Parameter(Mandatory=$false)]
    [int]$Threshold = 5
)

$Region = "us-east-1"
$TopicName = "billing-alert-topic"
$AlarmName = "Monthly-Billing-Alert-${Threshold}USD"

Write-Host "Creating SNS Topic: $TopicName..."
$TopicArn = (aws sns create-topic --name $TopicName --region $Region --query "TopicArn" --output text)

Write-Host "Subscribing $EmailAddress to $TopicArn..."
aws sns subscribe --topic-arn $TopicArn --protocol email --notification-endpoint $EmailAddress --region $Region

Write-Host "Creating CloudWatch Billing Alarm for > $$Threshold..."
aws cloudwatch put-metric-alarm `
    --alarm-name $AlarmName `
    --alarm-description "Alarm when AWS spending exceeds $$Threshold" `
    --metric-name "EstimatedCharges" `
    --namespace "AWS/Billing" `
    --statistic "Maximum" `
    --period 21600 `
    --evaluation-periods 1 `
    --threshold $Threshold `
    --comparison-operator "GreaterThanThreshold" `
    --dimensions "Name=Currency,Value=USD" `
    --alarm-actions $TopicArn `
    --region $Region

Write-Host "`n--- Setup Complete ---"
Write-Host "CloudWatch alarm '$AlarmName' created."
Write-Host "IMPORTANT: Please check your email ($EmailAddress) and click the link to confirm the SNS subscription."
