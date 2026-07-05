#!/bin/bash
# Test 1 - Create a user
CREATE_PAYLOAD='{"body":"{\"name\":\"Vinay Kumar\",\"email\":\"vinay@example.com\",\"role\":\"admin\"}","httpMethod":"POST","path":"/users"}'

aws lambda invoke \
  --function-name users-api \
  --payload "$CREATE_PAYLOAD" \
  --cli-binary-format raw-in-base64-out \
  response.json

cat response.json

# Test 2 - List all users
LIST_PAYLOAD='{"httpMethod":"GET","path":"/users"}'

aws lambda invoke \
  --function-name users-api \
  --payload "$LIST_PAYLOAD" \
  --cli-binary-format raw-in-base64-out \
  response-list.json

cat response-list.json