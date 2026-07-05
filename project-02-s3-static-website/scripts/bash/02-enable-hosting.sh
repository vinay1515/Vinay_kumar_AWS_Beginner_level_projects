#!/bin/bash
source ../../.env
aws s3api put-bucket-website --bucket "$BUCKET_NAME" --website-configuration '{"IndexDocument": {"Suffix": "index.html"},"ErrorDocument": {"Key": "error.html"}}'
