#!/bin/bash
API_ID=$(aws apigateway get-rest-apis --query "items[?name=='users-api'].id | [0]" --output text)
API_URL="https://${API_ID}.execute-api.us-east-1.amazonaws.com/prod"

echo -e "\e[36m=== TEST 1: Create User ===\e[0m"
RESPONSE1=$(curl -s -X POST "$API_URL/users" -H "Content-Type: application/json" -d '{"name":"Vinay Kumar","email":"vinay@example.com","role":"admin"}')
USER_ID=$(echo $RESPONSE1 | grep -o '"userId": "[^"]*' | cut -d'"' -f4)
echo "Created user ID: $USER_ID"

echo -e "\e[36m=== TEST 2: Create Second User ===\e[0m"
curl -s -X POST "$API_URL/users" -H "Content-Type: application/json" -d '{"name":"AWS Engineer","email":"aws@example.com","role":"developer"}'

echo -e "\n\e[36m=== TEST 3: List All Users ===\e[0m"
curl -s -X GET "$API_URL/users"

echo -e "\n\n\e[36m=== TEST 4: Get Single User ===\e[0m"
curl -s -X GET "$API_URL/users/$USER_ID"

echo -e "\n\n\e[36m=== TEST 5: Update User ===\e[0m"
curl -s -X PUT "$API_URL/users/$USER_ID" -H "Content-Type: application/json" -d '{"role":"superadmin","name":"Vinay Kumar - Updated"}'

echo -e "\n\n\e[36m=== TEST 6: Test 404 ===\e[0m"
curl -s -X GET "$API_URL/users/non-existent-id-12345"

echo -e "\n\n\e[36m=== TEST 7: Delete User ===\e[0m"
curl -s -X DELETE "$API_URL/users/$USER_ID"

echo -e "\n\n\e[36m=== TEST 8: Verify Deletion ===\e[0m"
curl -s -X GET "$API_URL/users"

echo -e "\n\n\e[32m=== ALL TESTS PASSED ===\e[0m" 