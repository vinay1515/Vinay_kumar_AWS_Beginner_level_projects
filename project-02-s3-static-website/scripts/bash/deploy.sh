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

if [ -z "$BUCKET_NAME" ] || [ -z "$AWS_REGION" ]; then
    echo -e "\e[31mError: BUCKET_NAME and AWS_REGION must be set in .env\e[0m"
    exit 1
fi

echo -e "\e[36mCreating S3 bucket: $BUCKET_NAME in region $AWS_REGION...\e[0m"
if [ "$AWS_REGION" == "us-east-1" ]; then
    aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$AWS_REGION"
else
    aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$AWS_REGION" --create-bucket-configuration LocationConstraint="$AWS_REGION"
fi

echo -e "\e[36mDisabling block public access...\e[0m"
aws s3api put-public-access-block \
  --bucket "$BUCKET_NAME" \
  --public-access-block-configuration \
  "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"

echo -e "\e[36mEnabling static website hosting...\e[0m"
aws s3api put-bucket-website \
  --bucket "$BUCKET_NAME" \
  --website-configuration '{
    "IndexDocument": {"Suffix": "index.html"},
    "ErrorDocument": {"Key": "error.html"}
  }'

echo -e "\e[36mApplying bucket policy...\e[0m"
aws s3api put-bucket-policy \
  --bucket "$BUCKET_NAME" \
  --policy '{
    "Version":"2012-10-17",
    "Statement":[{
      "Sid":"PublicReadGetObject",
      "Effect":"Allow",
      "Principal":"*",
      "Action":"s3:GetObject",
      "Resource":"arn:aws:s3:::'"$BUCKET_NAME"'/*"
    }]
  }'

SOURCE_PATH="../../website/"
if [ ! -d "$SOURCE_PATH" ]; then
    SOURCE_PATH="../website/"
fi

echo -e "\e[36mSyncing files from $SOURCE_PATH to S3 bucket: $BUCKET_NAME...\e[0m"
aws s3 sync "$SOURCE_PATH" s3://"$BUCKET_NAME"/ --region "$AWS_REGION"

echo -e "\e[32mDeployment complete. Bucket Website URL: http://$BUCKET_NAME.s3-website-$AWS_REGION.amazonaws.com\e[0m"
