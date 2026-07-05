# Testing Procedures

This document outlines the systematic tests required to validate the Two-Tier architecture, specifically ensuring that the EC2 instance can communicate with the RDS database, while the database remains completely isolated from the internet.

## ✅ Test 1: Validate EC2 Public Access

This test ensures that your Application Server is accessible from the internet and can be managed via SSH.

1. Obtain the **Public IP** of your `app-server` (located in `public-subnet-a`).
2. Open your terminal (or PuTTY) and SSH into the server:
   ```bash
   ssh -i aws-ec2-keypair.pem ec2-user@<APP_SERVER_PUBLIC_IP>
   ```
   **Expected Result:** You successfully connect to the EC2 instance.

## ✅ Test 2: Verify RDS Private Isolation

This test ensures that the database is not exposed to the public internet.

1. From your local workstation (NOT the EC2 instance), attempt to connect to the RDS endpoint:
   ```bash
   mysql -h <YOUR_RDS_ENDPOINT> -P 3306 -u admin -p
   ```
   **Expected Result:** The connection times out or is refused. The database resides in a private subnet and its security group (`rds-sg`) only accepts traffic from `ec2-app-sg`.

## ✅ Test 3: Validate Secrets Manager Access

This test proves that the IAM Instance Profile attached to the EC2 instance correctly grants permissions to read the database credentials.

1. From within the **EC2 terminal**, execute the following AWS CLI command:
   ```bash
   aws secretsmanager get-secret-value \
     --secret-id "rds/myapp/credentials" \
     --region us-east-1 \
     --query "SecretString" \
     --output text
   ```
   **Expected Result:** The command outputs the JSON string containing your username and password. This confirms the EC2 instance has securely retrieved the secret without it being hardcoded.

## ✅ Test 4: Validate EC2-to-RDS Connectivity

This is the most critical test. It proves that Security Group Chaining is working and the EC2 instance can query the database.

1. From within the **EC2 terminal**, verify the MySQL client is installed:
   ```bash
   mysql --version
   ```
   **Expected Result:** `mysql  Ver 8.0.x Distrib 8.0.x, for Linux (x86_64)`
2. Connect to the RDS instance using the endpoint and the credentials retrieved in Test 3:
   ```bash
   mysql -h <YOUR_RDS_ENDPOINT> -P 3306 -u admin -p
   ```
   *(Enter your password when prompted).*
   **Expected Result:** You successfully enter the MySQL monitor (`mysql>`).

## ✅ Test 5: Validate Database Read/Write Operations

This test ensures the database is fully functional and accepts standard SQL commands.

1. Inside the MySQL monitor, create and populate a test table:
   ```sql
   USE appdb;
   
   CREATE TABLE users (
       id          INT AUTO_INCREMENT PRIMARY KEY,
       name        VARCHAR(100) NOT NULL,
       email       VARCHAR(150) NOT NULL UNIQUE,
       role        VARCHAR(50)  DEFAULT 'user',
       created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
   );

   INSERT INTO users (name, email, role) VALUES
     ('Vinay Kumar',    'vinay@example.com',   'admin'),
     ('AWS Engineer',   'aws@example.com',     'developer'),
     ('Cloud Learner',  'cloud@example.com',   'user');
   ```
2. Query the data:
   ```sql
   SELECT * FROM users;
   ```
   **Expected Result:** 3 rows of data are returned.
3. Verify the underlying hostname to ensure you are talking to RDS:
   ```sql
   SELECT @@hostname;
   ```
   **Expected Result:** The output matches your RDS instance identifier, proving the queries ran on the managed database, not locally on the EC2 instance.

If all 5 tests pass, your Two-Tier architecture is mathematically proven to be correct!