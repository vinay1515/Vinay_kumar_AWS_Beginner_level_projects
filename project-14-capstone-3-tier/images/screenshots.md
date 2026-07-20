# Project 14 Screenshot List

Complete List (32 screenshots)

## Network Infrastructure
* **01-vpc-created.png**
  * **Where:** VPC console → Your VPCs
  * **Capture:** capstone-vpc with CIDR 10.0.0.0/16, DNS enabled
* **02-six-subnets-created.png**
  * **Where:** VPC console → Subnets → filter by capstone-vpc
  * **Capture:** All 6 subnets listed — public-a/b, app-a/b, db-a/b with CIDRs
* **03-igw-attached.png**
  * **Where:** VPC → Internet Gateways
  * **Capture:** capstone-igw State=Attached to capstone-vpc
* **04-nat-gateway-available.png**
  * **Where:** VPC → NAT Gateways
  * **Capture:** capstone-nat-gw State=Available in public-a subnet
* **05-route-tables.png**
  * **Where:** VPC → Route Tables → filter by capstone-vpc
  * **Capture:** public-rt (0.0.0.0/0→IGW) and private-rt (0.0.0.0/0→NAT)

## Security Groups
* **06-alb-security-group.png**
  * **Where:** EC2 → Security Groups → capstone-alb-sg
  * **Capture:** Inbound rules — port 80 and 443 from 0.0.0.0/0
* **07-app-security-group.png**
  * **Where:** EC2 → Security Groups → capstone-app-sg
  * **Capture:** Inbound — port 80/443 from alb-sg, port 22 from My IP
* **08-rds-security-group.png**
  * **Where:** EC2 → Security Groups → capstone-rds-sg
  * **Capture:** Inbound — port 3306 from app-sg (SG reference, not CIDR)
* **09-security-group-chain.png**
  * **Where:** Show all 3 SGs in same screenshot or side-by-side
  * **Capture:** Visual proof of the 3-tier security chain

## IAM and Secrets
* **10-iam-role-policies.png**
  * **Where:** IAM → capstone-app-role → Permissions tab
  * **Capture:** SSMCore, CloudWatchAgent, secrets-read inline policy listed
* **11-secrets-manager.png**
  * **Where:** Secrets Manager → capstone/db/credentials
  * **Capture:** Secret name, ARN, last retrieved date visible

## Tier 3 — RDS
* **12-rds-creating.png**
  * **Where:** RDS → Databases → capstone-mysql
  * **Capture:** Status=Creating, Multi-AZ=Yes (catch within first 2 minutes)
* **13-rds-available-multiz.png**
  * **Where:** RDS → capstone-mysql → Summary tab
  * **Capture:** Status=Available, Multi-AZ=Yes, Encrypted=Yes, Class=db.t3.micro
* **14-rds-connectivity.png**
  * **Where:** RDS → capstone-mysql → Connectivity & security tab
  * **Capture:** Endpoint URL, Port 3306, Publicly accessible=No, VPC=capstone-vpc
* **15-rds-subnet-group.png**
  * **Where:** RDS → Subnet groups → capstone-db-subnet-group
  * **Capture:** Both DB subnets listed, spans ap-south-1a and ap-south-1b

## Tier 2 — App (ASG + EC2)
* **16-launch-template.png**
  * **Where:** EC2 → Launch Templates → capstone-lt
  * **Capture:** AMI, t2.micro, capstone-app-sg, capstone-app-profile visible
* **17-asg-created.png**
  * **Where:** EC2 → Auto Scaling Groups → capstone-asg
  * **Capture:** Min=2, Max=4, Desired=2, Health check=ELB, in private subnets
* **18-asg-instances-running.png**
  * **Where:** EC2 → Auto Scaling Groups → capstone-asg → Instance management tab
  * **Capture:** Both instances InService, Healthy, in different AZs
* **19-ec2-in-private-subnet.png**
  * **Where:** EC2 → Instances → click one capstone-app-server
  * **Capture:** Instance in app subnet (10.0.3.x or 10.0.4.x), NO public IP

## Tier 1 — ALB
* **20-alb-active.png**
  * **Where:** EC2 → Load Balancers → capstone-alb
  * **Capture:** State=Active, Scheme=internet-facing, in public subnets
* **21-target-group-healthy.png**
  * **Where:** EC2 → Target Groups → capstone-tg → Targets tab
  * **Capture:** Both instances showing healthy (green), /health check passing
* **22-alb-listener.png**
  * **Where:** EC2 → Load Balancers → capstone-alb → Listeners tab
  * **Capture:** HTTP:80 listener forwarding to capstone-tg

## Application Live
* **23-app-browser-tier-display.png**
  * **Where:** Browser at http://ALB_DNS_NAME
  * **Capture:** Full 3-tier page showing Web/App/DB tiers, instance ID, AZ
* **24-app-browser-second-instance.png**
  * **Where:** Same URL after Ctrl+Shift+R (hard refresh)
  * **Capture:** Different Instance ID proving load balancing across AZs
* **25-health-endpoint.png**
  * **Where:** Browser at http://ALB_DNS/health OR PowerShell output
  * **Capture:** Returns "OK" — confirms health check endpoint works

## DB Connection Verified
* **26-mysql-connected-from-app.png**
  * **Where:** SSM terminal on app server
  * **Capture:** MySQL prompt connected to RDS endpoint, Shows: mysql> prompt with @@hostname showing RDS hostname
* **27-mysql-table-created.png**
  * **Where:** SSM terminal → MySQL prompt
  * **Capture:** CREATE TABLE and SELECT * FROM app_requests showing data

## Monitoring
* **28-cloudwatch-alarms.png**
  * **Where:** CloudWatch → Alarms → All alarms
  * **Capture:** All 4 capstone alarms listed (OK state, green)
* **29-cloudwatch-dashboard.png**
  * **Where:** CloudWatch → Dashboards → capstone-dashboard
  * **Capture:** Full dashboard with ALB, ASG CPU, RDS CPU, RDS connections widgets
* **30-sns-topic.png**
  * **Where:** SNS → Topics → capstone-alerts
  * **Capture:** Topic ARN and subscription confirmed
