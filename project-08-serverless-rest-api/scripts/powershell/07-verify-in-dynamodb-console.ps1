# Check items in DynamoDB via CLI
aws dynamodb scan `
  --table-name users `
  --query "Items[*].{ID:userId.S,Name:name.S,Email:email.S,Role:role.S}" `
  --output table