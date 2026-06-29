#!/bin/bash

#Requires -Version 5.1
<#
.SYNOPSIS
Empties and deletes the S3 bucket.
#>

param (
    [Parameter(Mandatory=$true)]
    [string]$BucketName
)

echo -e "\e[33mEmptying bucket $BucketName...\e[0m"
aws s3 rm s3://$BucketName --recursive

echo -e "\e[33mDeleting bucket $BucketName...\e[0m"
aws s3api delete-bucket --bucket $BucketName --region us-east-1

echo -e "\e[32mBucket cleanup complete. Remember to disable and delete your CloudFront distribution in the console.\e[0m"
