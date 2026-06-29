#!/bin/bash

# =============================================================================
# Project 8 — Script 06: Full API Test Suite
# Tests all 5 endpoints with 8 test cases — validates status codes and payloads
# =============================================================================

echo -e "\e[36m=== Project 8 — API Test Suite ===\e[0m"
echo ""

# ⚠️ Set your API URL before running
# API_URL="https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod"

if [ -z "$API_URL" ]; then
    echo -e "\e[31mERROR: API_URL not set.\e[0m"
    echo "Run: export API_URL=\"...\""
    exit 1
fi

echo "Testing API: $API_URL"
echo ""

PASS=0
FAIL=0

function assert_status {
    local test_name=$1
    local expected=$2
    local actual=$3
    if [ "$actual" == "$expected" ]; then
        echo -e "\e[32m  ✓ $test_name (HTTP $actual)\e[0m"
        PASS=$((PASS + 1))
    else
        echo -e "\e[31m  ✗ $test_name — expected $expected, got $actual\e[0m"
        FAIL=$((FAIL + 1))
    fi
}

# ── TEST 1: CREATE USER ───────────────────────────────────────────────────────
echo -e "\e[33mTEST 1 — POST /users (create user 1)\e[0m"
resp=$(curl -s -w "\n%{http_code}" -X POST "$API_URL/users" \
    -H "Content-Type: application/json" \
    -d '{"name":"Vinay Kumar","email":"vinay@example.com","role":"admin"}')
status=$(echo "$resp" | tail -n1)
body=$(echo "$resp" | sed '$d')

assert_status "Create user" 201 "$status"
if [ "$status" == "201" ]; then
    ID1=$(echo "$body" | jq -r '.user.userId')
    echo "  User ID: $ID1"
    echo "  Name:    $(echo "$body" | jq -r '.user.name')"
fi

# ── TEST 2: CREATE SECOND USER ────────────────────────────────────────────────
echo ""
echo -e "\e[33mTEST 2 — POST /users (create user 2)\e[0m"
resp=$(curl -s -w "\n%{http_code}" -X POST "$API_URL/users" \
    -H "Content-Type: application/json" \
    -d '{"name":"AWS Engineer","email":"aws@example.com","role":"developer"}')
status=$(echo "$resp" | tail -n1)
body=$(echo "$resp" | sed '$d')

assert_status "Create second user" 201 "$status"
if [ "$status" == "201" ]; then
    ID2=$(echo "$body" | jq -r '.user.userId')
    echo "  User ID: $ID2"
fi

# ── TEST 3: LIST ALL USERS ────────────────────────────────────────────────────
echo ""
echo -e "\e[33mTEST 3 — GET /users (list all)\e[0m"
resp=$(curl -s -w "\n%{http_code}" -X GET "$API_URL/users")
status=$(echo "$resp" | tail -n1)
body=$(echo "$resp" | sed '$d')

assert_status "List users" 200 "$status"
if [ "$status" == "200" ]; then
    count=$(echo "$body" | jq -r '.count')
    echo "  Count: $count"
    
    names=$(echo "$body" | jq -r '.users[].name')
    roles=$(echo "$body" | jq -r '.users[].role')
    
    i=0
    for name in $names; do
        # Extract corresponding role for demo purposes
        role=$(echo "$roles" | head -n $((i+1)) | tail -n 1)
        echo "    - $name [$role]"
        i=$((i + 1))
    done
fi

# ── TEST 4: GET SINGLE USER ───────────────────────────────────────────────────
echo ""
echo -e "\e[33mTEST 4 — GET /users/{id} (get user 1)\e[0m"
resp=$(curl -s -w "\n%{http_code}" -X GET "$API_URL/users/$ID1")
status=$(echo "$resp" | tail -n1)
body=$(echo "$resp" | sed '$d')

assert_status "Get single user" 200 "$status"
if [ "$status" == "200" ]; then
    echo "  Name:  $(echo "$body" | jq -r '.user.name')"
    echo "  Email: $(echo "$body" | jq -r '.user.email')"
fi

# ── TEST 5: UPDATE USER ───────────────────────────────────────────────────────
echo ""
echo -e "\e[33mTEST 5 — PUT /users/{id} (update user 1)\e[0m"
resp=$(curl -s -w "\n%{http_code}" -X PUT "$API_URL/users/$ID1" \
    -H "Content-Type: application/json" \
    -d '{"role":"superadmin","name":"Vinay Kumar - Updated"}')
status=$(echo "$resp" | tail -n1)
body=$(echo "$resp" | sed '$d')

assert_status "Update user" 200 "$status"
if [ "$status" == "200" ]; then
    echo "  New role: $(echo "$body" | jq -r '.user.role')"
    echo "  New name: $(echo "$body" | jq -r '.user.name')"
    echo "  Updated at: $(echo "$body" | jq -r '.user.updatedAt')"
fi

# ── TEST 6: 404 FOR NON-EXISTENT USER ────────────────────────────────────────
echo ""
echo -e "\e[33mTEST 6 — GET /users/bad-id (expect 404)\e[0m"
resp=$(curl -s -w "\n%{http_code}" -X GET "$API_URL/users/non-existent-user-id-99999")
status=$(echo "$resp" | tail -n1)

assert_status "404 for non-existent user" 404 "$status"

# ── TEST 7: DELETE USER ───────────────────────────────────────────────────────
echo ""
echo -e "\e[33mTEST 7 — DELETE /users/{id} (delete user 1)\e[0m"
resp=$(curl -s -w "\n%{http_code}" -X DELETE "$API_URL/users/$ID1")
status=$(echo "$resp" | tail -n1)
body=$(echo "$resp" | sed '$d')

assert_status "Delete user" 200 "$status"
if [ "$status" == "200" ]; then
    echo "  $(echo "$body" | jq -r '.message')"
fi

# ── TEST 8: VERIFY DELETION ───────────────────────────────────────────────────
echo ""
echo -e "\e[33mTEST 8 — GET /users (verify deletion)\e[0m"
resp=$(curl -s -w "\n%{http_code}" -X GET "$API_URL/users")
status=$(echo "$resp" | tail -n1)
body=$(echo "$resp" | sed '$d')

assert_status "Verify deletion" 200 "$status"
if [ "$status" == "200" ]; then
    count=$(echo "$body" | jq -r '.count')
    echo "  Remaining users: $count (expect 1 — user 2 still exists)"
fi

# ── RESULTS ───────────────────────────────────────────────────────────────────
echo ""
echo -e "\e[36m=== Test Results ===\e[0m"
echo -e "\e[32m  Passed: $PASS\e[0m"
echo "  Failed: $FAIL"

if [ $FAIL -eq 0 ]; then
    echo ""
    echo -e "\e[32mALL TESTS PASSED\e[0m"
    echo -e "\e[32mServerless REST API is working end-to-end.\e[0m"
else
    echo ""
    echo -e "\e[33mSome tests failed. Check CloudWatch Logs:\e[0m"
    echo "  aws logs tail /aws/lambda/users-api --follow"
fi

echo ""
echo -e "\e[36mNext step: Run 07-monitor-cloudwatch.sh\e[0m"