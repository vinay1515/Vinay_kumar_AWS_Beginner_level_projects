# Architecture Details

## The Application Tier (EC2)
- Resides in a Public Subnet to serve web traffic.
- Configured with an IAM Role that grants `secretsmanager:GetSecretValue`, allowing it to read the database password dynamically.
- `Web-SG` allows inbound HTTP (80) and SSH (22).

## The Database Tier (RDS)
- **Engine:** MySQL 8.0 running on a `db.t3.micro` instance.
- **Network:** Deployed in a DB Subnet Group consisting of two Private Subnets.
- **Security:** `DB-SG` allows inbound port 3306 (MySQL) *only* from the ID of the `Web-SG`.

## AWS Secrets Manager
Stores the JSON dictionary containing the username, password, engine, port, and dbname, preventing credential exposure in plaintext scripts.