#!/bin/bash
# Repackage
zip -j lambda/function.zip lambda/lambda_function.py

# Deploy update
aws lambda update-function-code \
  --function-name users-api \
  --zip-file fileb://lambda/function.zip

# Wait for update to complete
aws lambda wait function-updated --function-name users-api
echo "Lambda updated successfully" 