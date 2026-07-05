#!/bin/bash
source ../../.env
aws s3 sync ../../website/ s3://"$BUCKET_NAME"/ --region "$AWS_REGION"
