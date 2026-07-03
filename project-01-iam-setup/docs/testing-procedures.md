# Testing Procedures

To verify your IAM setup is working correctly via the CLI, run the following command in your terminal:

```bash
aws sts get-caller-identity
```

### Expected Output
```json
{
    "UserId": "AIDAxxxxxxxxxxxx",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/admin-yourname"
}
```
If the Arn returns your newly created IAM user, the setup is successful.