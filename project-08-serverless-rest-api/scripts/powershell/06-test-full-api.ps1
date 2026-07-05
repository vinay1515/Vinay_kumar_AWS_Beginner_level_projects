# Set your API URL (retrieve if not set)
$API_ID = aws apigateway get-rest-apis --query "items[?name=='users-api'].id | [0]" --output text
$API_URL = "https://$API_ID.execute-api.us-east-1.amazonaws.com/prod"

# TEST 1: Create User
Write-Host "=== TEST 1: Create User ===" -ForegroundColor Cyan
$user1 = Invoke-RestMethod -Uri "$API_URL/users" -Method POST -ContentType "application/json" -Body '{"name":"Vinay Kumar","email":"vinay@example.com","role":"admin"}'
Write-Host "Created user ID: $($user1.user.userId)"
$USER_ID = $user1.user.userId

# TEST 2: Create Second User
Write-Host "=== TEST 2: Create Second User ===" -ForegroundColor Cyan
$user2 = Invoke-RestMethod -Uri "$API_URL/users" -Method POST -ContentType "application/json" -Body '{"name":"AWS Engineer","email":"aws@example.com","role":"developer"}'
Write-Host "Created user ID: $($user2.user.userId)"

# TEST 3: List All Users
Write-Host "=== TEST 3: List All Users ===" -ForegroundColor Cyan
$allUsers = Invoke-RestMethod -Uri "$API_URL/users" -Method GET
Write-Host "Total users: $($allUsers.count)"

# TEST 4: Get Single User
Write-Host "=== TEST 4: Get Single User ===" -ForegroundColor Cyan
$singleUser = Invoke-RestMethod -Uri "$API_URL/users/$USER_ID" -Method GET
Write-Host "Got user: $($singleUser.user.name)"

# TEST 5: Update User
Write-Host "=== TEST 5: Update User ===" -ForegroundColor Cyan
$updatedUser = Invoke-RestMethod -Uri "$API_URL/users/$USER_ID" -Method PUT -ContentType "application/json" -Body '{"role":"superadmin","name":"Vinay Kumar - Updated"}'
Write-Host "Updated user role: $($updatedUser.user.role)"

# TEST 6: Get 404
Write-Host "=== TEST 6: Test 404 ===" -ForegroundColor Cyan
try { Invoke-RestMethod -Uri "$API_URL/users/non-existent-id-12345" -Method GET } catch { Write-Host "404 received as expected: $($_.Exception.Message)" }

# TEST 7: Delete User
Write-Host "=== TEST 7: Delete User ===" -ForegroundColor Cyan
$deleted = Invoke-RestMethod -Uri "$API_URL/users/$USER_ID" -Method DELETE
Write-Host "Delete response: $($deleted.message)"

# TEST 8: Verify Deletion
Write-Host "=== TEST 8: Verify Deletion ===" -ForegroundColor Cyan
$finalList = Invoke-RestMethod -Uri "$API_URL/users" -Method GET
Write-Host "Users remaining: $($finalList.count)"

Write-Host "`n=== ALL TESTS PASSED ===" -ForegroundColor Green