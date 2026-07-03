# Troubleshooting

| Issue | Cause | Fix |
|---|---|---|
| **Connection Timeout to RDS** | Security Group chaining | Ensure the `DB-SG` inbound rule explicitly references the `Web-SG` ID and is set to port 3306. Verify EC2 is actually attached to `Web-SG`. |
| **Secrets Manager AccessDenied** | Missing IAM Role | The EC2 instance must have an IAM Instance Profile attached that contains a policy granting `secretsmanager:GetSecretValue`. |
| **Cannot create DB Subnet Group** | Subnet AZ count | DB Subnet Groups MUST cover at least 2 Availability Zones for high availability. Ensure your private subnets are in different AZs. |