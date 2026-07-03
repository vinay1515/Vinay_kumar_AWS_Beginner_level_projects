# Security Protocols

- **Isolation:** Setting `PubliclyAccessible=false` ensures the RDS instance is never given a public IP address. It is strictly available within the VPC boundary.
- **Credential Rotation:** By utilizing AWS Secrets Manager instead of Parameter Store or hardcoded `.env` files, the database credentials can be configured to rotate automatically on a schedule, natively updating the database and application simultaneously.
- **Zero-Trust Network:** Even if an attacker gains access to a machine inside the VPC, they cannot reach the database unless their machine possesses the exact Security Group (`Web-SG`) authorized by the `DB-SG`.