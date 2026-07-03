# Security Protocols

- **Network Isolation:** By restricting SSH (port 22) to your specific public IP address, bots scanning the internet cannot brute-force your server.
- **Agent-Based Access:** AWS Systems Manager (SSM) Session Manager represents the modern standard for terminal access. Because it operates via outbound HTTPS polling from the SSM Agent on the instance to the AWS API, it does not require opening *any* inbound ports for administration.
- **Identity-Based Credentials:** By attaching an IAM Role to the instance, the AWS credentials needed for SSM are dynamically generated and rotated by AWS, avoiding hard-coded keys on the server.