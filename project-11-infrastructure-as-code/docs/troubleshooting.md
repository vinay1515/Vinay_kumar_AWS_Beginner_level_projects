# Troubleshooting

| Issue | Cause | Fix |
|---|---|---|
| **Syntax Errors / Indentation** | YAML Formatting | YAML relies strictly on indentation. Use a linter or `aws cloudformation validate-template` to catch indentation errors. |
| **Circular Dependency** | Resource References | You cannot have Resource A depend on Resource B while Resource B depends on Resource A. Redesign the architecture. |
| **Stack stuck in DELETE_FAILED** | Manual Deletion | If you manually delete a resource (like an S3 bucket) that CloudFormation was tracking, it will fail to delete the stack. You must choose "Skip Resource" when retrying the stack deletion. |
