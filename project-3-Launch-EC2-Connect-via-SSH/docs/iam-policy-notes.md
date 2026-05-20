## Project 3 — EC2 SSM Instance Profile Role

Role name: ec2-ssm-role
Attached to: EC2 instance via instance profile
Effect: Allows EC2 to communicate with AWS Systems Manager

Policy attached: AmazonSSMManagedInstanceCore (AWS Managed)
This policy allows:
- ssm:UpdateInstanceInformation
- ssmmessages:* (Session Manager tunnel)
- ec2messages:* (SSM agent communication)
- s3:GetObject on SSM-owned S3 buckets (for agent updates)

### Why a role and not an access key?
EC2 instances should NEVER have access keys hardcoded.
Instead attach an IAM role — the instance gets temporary
rotating credentials automatically. This is the correct
pattern for ALL AWS services (Lambda, ECS, CodeBuild etc.)

### Security group rules created:
Port 22  TCP  MY_IP/32     → SSH (restricted to my IP only)
Port 80  TCP  0.0.0.0/0   → HTTP (open to public for web server)
Port 443 TCP  (mini challenge) → HTTPS

### Key insight:
Session Manager needs ZERO open inbound ports.
It works over HTTPS outbound from the instance to SSM endpoints.
This means you can remove port 22 entirely and still connect.
Production environments often do exactly this.