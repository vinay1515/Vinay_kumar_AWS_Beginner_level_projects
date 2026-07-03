#!/bin/bash
# Load environment variables
if [ -f "../../.env" ]; then
    source ../../.env
elif [ -f "../.env" ]; then
    source ../.env
elif [ -f ".env" ]; then
    source .env
else
    echo -e "\e[31mError: .env file not found.\e[0m"
    exit 1
fi

if [ -z "$DISTRIBUTION_ID" ]; then
    echo -e "\e[31mError: DISTRIBUTION_ID must be set in .env\e[0m"
    exit 1
fi

echo -e "\e[36mCreating CloudFront cache invalidation for distribution: $DISTRIBUTION_ID...\e[0m"
aws cloudfront create-invalidation \
  --distribution-id "$DISTRIBUTION_ID" \
  --paths "/*"

echo -e "\e[32mInvalidation request submitted.\e[0m"
