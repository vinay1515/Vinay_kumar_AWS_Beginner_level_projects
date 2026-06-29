#!/bin/bash

#Requires -Version 5.1
<#
.SYNOPSIS
Invalidates the CloudFront cache to force edge locations to fetch new S3 files.
#>

param (
    [Parameter(Mandatory=$true)]
    [string]$DistributionId
)

echo -e "\e[36mRequesting cache invalidation for distribution: $DistributionId...\e[0m"
aws cloudfront create-invalidation --distribution-id $DistributionId --paths "/*"

echo -e "\e[32mInvalidation requested. It will take a few moments to propagate.\e[0m"
