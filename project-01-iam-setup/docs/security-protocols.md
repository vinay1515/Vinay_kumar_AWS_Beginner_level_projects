# Security Protocols

> [!IMPORTANT]
> Security is the absolute priority when managing an AWS account. A compromised root account means losing the entire AWS environment.

- **Principle of Least Privilege:** Although the admin user has `AdministratorAccess`, it is still better than root because IAM users cannot close the account or change AWS support plans.
- **MFA Enforcement:** Multi-Factor authentication ensures that even if a password is stolen, the account cannot be accessed.
- **Access Key Rotation:** It is highly recommended to rotate (delete and recreate) your AWS CLI access keys every 90 days.