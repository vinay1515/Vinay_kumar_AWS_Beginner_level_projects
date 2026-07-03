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

echo -e "\e[33mNOTE: For CloudFront distribution ($DISTRIBUTION_ID), please disable and delete it via the AWS Console.\e[0m"
echo -e "\e[33mCloudFront -> Distributions -> Select yours -> Disable -> wait 5 min -> Delete\e[0m"

if [ -n "$BUCKET_NAME" ]; then
    echo -e "\e[36mEmptying S3 bucket: $BUCKET_NAME...\e[0m"
    aws s3 rm s3://"$BUCKET_NAME" --recursive

    echo -e "\e[36mDeleting S3 bucket: $BUCKET_NAME...\e[0m"
    aws s3api delete-bucket --bucket "$BUCKET_NAME" --region "$AWS_REGION"
fi

echo -e "\e[32mS3 Cleanup complete.\e[0m"
