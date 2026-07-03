# Testing Procedures

1. SSH into your EC2 App Server.
2. Install the MySQL client:
   ```bash
   sudo dnf install -y mysql
   ```
3. Fetch the DB Endpoint from the RDS Console (e.g., `myapp.xxxx.us-east-1.rds.amazonaws.com`).
4. Connect to the database from the EC2 terminal:
   ```bash
   mysql -h <ENDPOINT> -u <USERNAME> -p
   ```
5. Enter the password when prompted.
6. Once connected, execute SQL commands:
   ```sql
   SHOW DATABASES;
   CREATE DATABASE appdb;
   USE appdb;
   CREATE TABLE users (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(100));
   INSERT INTO users (name) VALUES ('Test User');
   SELECT * FROM users;
   ```