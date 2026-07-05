#!/bin/bash
source ../../.env
aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$AWS_REGION"
