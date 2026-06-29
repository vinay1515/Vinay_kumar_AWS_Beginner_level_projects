#!/bin/bash

# =============================================================================
# Project 8 — Script 03: Package Lambda Function
# Zips lambda_function.py into function.zip for deployment
# =============================================================================

echo -e "\e[36m=== Project 8 — Package Lambda ===\e[0m"
echo ""

# Verify source file exists
if (-not (Test-Path "lambda\lambda_function.py")) {
echo -e "\e[31mERROR: lambda\lambda_function.py not found.\e[0m"
echo "Ensure you are running this from the project root directory."
echo "Expected: project-08-serverless-rest-api\"
    exit 1
}

echo -e "\e[33mSource file: lambda\lambda_function.py\e[0m"
echo "Output:      lambda\function.zip"
echo ""

# Remove old zip if exists
if (Test-Path "lambda\function.zip") {
    Remove-Item "lambda\function.zip"
echo "Removed existing function.zip"
}

# Package
Compress-Archive \
  -Path lambda\lambda_function.py \
  -DestinationPath lambda\function.zip

# Verify
ZIP=Get-Item "lambda\function.zip"
echo ""
echo -e "\e[32mPackage created successfully:\e[0m"
echo "  File:    $($ZIP.FullName)"
echo "  Size:    $($ZIP.Length) bytes"
echo ""

if ($ZIP.Length -lt 500) {
echo -e "\e[33mWARNING: Zip file is very small. Verify lambda_function.py has content.\e[0m"
}

echo -e "\e[36m=== Package Complete ===\e[0m"
echo -e "\e[36mNext step: Run 04-deploy-lambda.ps1\e[0m"