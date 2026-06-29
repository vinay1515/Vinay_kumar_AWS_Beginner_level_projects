#!/bin/bash

#Requires -Version 5.1
<#
.SYNOPSIS
Syncs local HTML files to the designated S3 bucket.
#>

param (
    [Parameter(Mandatory=$true)]
    [string]$BucketName
)

SourcePath="..\website\"

echo -e "\e[36mSyncing files to S3 bucket: $BucketName...\e[0m"
aws s3 sync $SourcePath s3://$BucketName/ --region us-east-1

echo -e "\e[32mDeployment complete.\e[0m"
