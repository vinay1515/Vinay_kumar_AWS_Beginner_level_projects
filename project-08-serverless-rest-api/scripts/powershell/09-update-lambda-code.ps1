# Repackage
Compress-Archive `
  -Path lambda\lambda_function.py `
  -DestinationPath lambdaunction.zip `
  -Force

# Deploy update
aws lambda update-function-code `
  --function-name users-api `
  --zip-file fileb://lambda/function.zip

# Wait for update to complete
aws lambda wait function-updated --function-name users-api
Write-Host "Lambda updated successfully" 