<#
.SYNOPSIS
Creates an IAM Admin user, attaches AdministratorAccess, and generates access keys.

.DESCRIPTION
This script automates Checkpoint C of the IAM Setup project.
It will output the Access Key ID and Secret Access Key to the console and a CSV file.
#>

param (
    [Parameter(Mandatory=$true)]
    [string]$UserName
)

Write-Host "Creating IAM User: $UserName..."
aws iam create-user --user-name $UserName

Write-Host "Attaching AdministratorAccess policy..."
aws iam attach-user-policy --user-name $UserName --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

Write-Host "Enabling console access..."
# Generate a random password for console access
$Password = -join ((33..126) | Get-Random -Count 16 | ForEach-Object {[char]$_})
aws iam create-login-profile --user-name $UserName --password $Password --password-reset-required

Write-Host "Creating access keys for programmatic access..."
$AccessKey = aws iam create-access-key --user-name $UserName | ConvertFrom-Json

$KeyId = $AccessKey.AccessKey.AccessKeyId
$Secret = $AccessKey.AccessKey.SecretAccessKey

Write-Host "`n--- Setup Complete ---"
Write-Host "IAM User: $UserName"
Write-Host "Console Password: $Password"
Write-Host "Access Key ID: $KeyId"
Write-Host "Secret Access Key: $Secret"

# Save to CSV
$CsvContent = "User Name,Password,Access key ID,Secret access key,Console login link`n"
$AccountID = (aws sts get-caller-identity --query "Account" --output text)
$LoginLink = "https://$AccountID.signin.aws.amazon.com/console"
$CsvContent += "$UserName,$Password,$KeyId,$Secret,$LoginLink"
$CsvPath = ".\$UserName-credentials.csv"
$CsvContent | Out-File -FilePath $CsvPath -Encoding utf8

Write-Host "`nCredentials saved to $CsvPath"
Write-Host "IMPORTANT: Keep this file secure or delete it after configuring AWS CLI."
