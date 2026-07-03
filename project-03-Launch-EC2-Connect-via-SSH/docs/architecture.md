# Architecture Overview

```mermaid
flowchart TD
    subgraph "Your Windows PC"
        PuTTY["PuTTY (SSH port 22)"]
        SSMClient["SSM Session Manager (HTTPS port 443)"]
    end

    subgraph "AWS Cloud"
        subgraph "Default VPC"
            subgraph "Security Group (ec2-web-sg)"
                EC2["EC2 Instance (Amazon Linux 2023)"]
                Apache["Apache Web Server (Port 80)"]
            end
        end
    end

    PuTTY -->|SSH (Port 22)| EC2
    SSMClient -->|HTTPS (Port 443)| EC2
    Internet((Internet)) -->|HTTP (Port 80)| Apache
    EC2 --- Apache
```

## Data Flow
1. **SSH Access**: You connect to the EC2 instance securely using the generated `.ppk` key pair via PuTTY over Port 22.
2. **SSM Access**: Alternatively, you connect via browser or CLI using AWS Systems Manager, which uses an outbound HTTPS connection, eliminating the need to open inbound SSH ports.
3. **Web Access**: End users (the Internet) access the hosted application via HTTP on Port 80, served by the Apache Web Server running on the EC2 instance.